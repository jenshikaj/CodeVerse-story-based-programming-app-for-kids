import os
import random
import re
import time
import firebase_admin
from firebase_admin import credentials, firestore
from flask import Flask, request, jsonify
import google.generativeai as genai
from dotenv import load_dotenv

# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------

load_dotenv()

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise RuntimeError(
        "GEMINI_API_KEY is not set. Create a file named .env in the backend "
    )

MODEL_NAME = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash")

LANGUAGE = "English"

SERVICE_ACCOUNT_FILE = "serviceAccountKey.json"

if os.path.exists(SERVICE_ACCOUNT_FILE):
    firebase_admin.initialize_app(credentials.Certificate(SERVICE_ACCOUNT_FILE))
else:
    firebase_admin.initialize_app()

db = firestore.client()
genai.configure(api_key=GEMINI_API_KEY)

app = Flask(__name__)

CHARACTER_NAMES = [
    "Amara", "Nithya", "Diego", "Leilani", "Kofi", "Mira", "Tomas", "Zara",
    "Ravi", "Sena", "Malik", "Yuki", "Ines", "Bilal", "Anaya", "Theo",
    "Layla", "Kian", "Noor", "Esi", "Arjun", "Freya", "Hana", "Oyin",
    "Dmitri", "Priya", "Sam", "Talia", "Idris", "Meilin", "Rafa", "Ada",
]

OVERUSED_NAMES = "Pip, Pippa, Lily, Leo, Milo, Max, Sam the squirrel"


# --------------------------------------------------------------------------
# Story generation
# --------------------------------------------------------------------------

class StoryGenerator:
    """Generates an English children's story, a title, MCQs and hints via Gemini."""

    def __init__(self):
        self.model = genai.GenerativeModel(MODEL_NAME)

    # -- helpers ----------------------------------------------------------

    def _generate(self, prompt, temperature=0.7):
        """
        Single point of contact with the Gemini API.

        Temperature is set per call. Creative writing wants a high value;
        the MCQ step wants a low one, because parse_mcqs() depends on the
        exact output format and a adventurous model starts improvising it.
        """
        response = self.model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=temperature,
                top_p=0.95,
            ),
        )
        if not hasattr(response, "text") or not response.text.strip():
            raise RuntimeError("Gemini returned an empty response.")
        return response.text.strip()

    @staticmethod
    def _strip_markdown_heading(text):
        return text[3:].lstrip() if text.startswith("## ") else text

    # -- generation steps -------------------------------------------------

    def generate_story(self, concept, genre, character_name):
        prompt = (
            f"Write an original children's story in English that clearly "
            f"explains the programming concept '{concept}' using a {genre} "
            f"theme.\n\n"
            f"Requirements:\n"
            f"- The {genre} theme should shape the setting, mood and events "
            f"of the story.\n"
            f"- The concept '{concept}' must drive the plot. The main "
            f"character should solve a real problem by using it, not simply "
            f"have it explained to them.\n"
            f"- Name the main character {character_name}.\n"
            f"- Do not use these overused names anywhere: {OVERUSED_NAMES}.\n"
            f"- Do not include a title.\n"
            f"- Write for ages 8 to 12: clear language, warm tone, roughly "
            f"500 to 700 words.\n"
            f"- Make this story distinct from typical examples of the genre."
        )
        return self._strip_markdown_heading(self._generate(prompt, temperature=1.0))

    def generate_title(self, story_text):
        prompt = (
            f"Provide a single, short, engaging title in English for this "
            f"children's story. Reply with the title only - no preamble, no "
            f"quotes, no markdown.\n\nStory:\n{story_text}"
        )
        title = self._strip_markdown_heading(self._generate(prompt, temperature=0.9))
        return title.split("\n")[0].strip()

    def generate_mcqs(self, story_text, concept, num_questions=5):
        prompt = (
            f"Based on the following story, create exactly {num_questions} "
            f"multiple-choice questions in English that test whether kids have "
            f"understood the programming concept '{concept}'. Questions must "
            f"relate directly to the concept as presented in the story.\n\n"
            f"Use this exact format for every question:\n\n"
            f"**Question X:**\nQuestion text here\n"
            f"(A) Option A\n(B) Option B\n(C) Option C\n(D) Option D\n"
            f"**Correct Answer: A**\n\n"
            f"Vary which letter is correct across the questions.\n\n"
            f"Here is the story:\n\n{story_text}"
        )
        return self._generate(prompt, temperature=0.4)

    def generate_hints(self, questions):
        """
        Generates all hints in ONE API call.

        The original version made one call per question, which meant eight
        sequential round-trips per story. This cuts it to four.
        """
        if not questions:
            return []

        numbered = "\n".join(f"{i + 1}. {q}" for i, q in enumerate(questions))

        prompt = (
            f"Provide one short, child-friendly hint in English for each of the "
            f"{len(questions)} questions below. A hint should nudge the child "
            f"towards the answer without revealing it.\n\n"
            f"Use this exact format, one line per hint:\n"
            f"**Hint 1:** hint text\n"
            f"**Hint 2:** hint text\n\n"
            f"Questions:\n{numbered}"
        )

        try:
            raw = self._generate(prompt, temperature=0.5)
        except Exception as e:
            print(f"Hint generation failed: {e}")
            return ["Hint not available."] * len(questions)

        found = re.findall(
            r"\*\*Hint\s*\d+:?\*\*:?\s*(.*?)(?=\*\*Hint\s*\d+|\Z)",
            raw,
            re.DOTALL,
        )
        hints = [h.strip() for h in found if h.strip()]

        while len(hints) < len(questions):
            hints.append("Hint not available.")
        return hints[:len(questions)]

    # -- parsing ----------------------------------------------------------

    def parse_mcqs(self, mcqs_text):
        """Extracts questions, options, correct answers and hints."""

        question_pattern = r"\*\*Question\s*\d+:?\*\*:?\s*(.*?)(?:\n|$)"
        options_pattern = (
            r"\(A\)\s*(.*?)\s*\n"
            r"\(B\)\s*(.*?)\s*\n"
            r"\(C\)\s*(.*?)\s*\n"
            r"\(D\)\s*(.*?)\s*(?:\n|$)"
        )
        correct_answer_pattern = r"\*\*Correct Answer:?\*?\*?:?\s*([A-D])"

        questions_found = re.findall(question_pattern, mcqs_text)
        options_found = re.findall(options_pattern, mcqs_text)
        correct_found = re.findall(correct_answer_pattern, mcqs_text)

        print(f"Parsed -> questions: {len(questions_found)}, "
              f"options: {len(options_found)}, answers: {len(correct_found)}")

        questions = [q.strip() for q in questions_found]
        options_list = [
            {
                "A": o[0].strip(),
                "B": o[1].strip(),
                "C": o[2].strip(),
                "D": o[3].strip(),
            }
            for o in options_found
        ]
        correct_answers = [a.strip() for a in correct_found]

        n = min(len(questions), len(options_list), len(correct_answers))
        if n == 0:
            raise ValueError(
                "Could not parse any questions from the model output. "
                "The response format may have changed."
            )
        if not (len(questions) == len(options_list) == len(correct_answers)):
            print(f"Warning: count mismatch, trimming all lists to {n}.")

        questions = questions[:n]
        options_list = options_list[:n]
        correct_answers = correct_answers[:n]

        hints = self.generate_hints(questions)

        return questions, options_list, correct_answers, hints


# --------------------------------------------------------------------------
# Routes
# --------------------------------------------------------------------------

@app.route("/health", methods=["GET"])
def health():
    """Quick check that the server is up and which model it is configured for."""
    return jsonify({"status": "ok", "model": MODEL_NAME}), 200


@app.route("/models", methods=["GET"])
def list_models():
    """
    Lists every model your API key can actually call.
    Useful when a model name stops working - check here first.
    """
    try:
        names = [
            m.name for m in genai.list_models()
            if "generateContent" in m.supported_generation_methods
        ]
        return jsonify({"available_models": names}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/generate_story", methods=["POST"])
def generate_story_endpoint():
    started = time.time()

    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "Request body must be JSON."}), 400

    print(f"Received data: {data}")

    concept = data.get("concept")
    genre = data.get("genre")
    email = data.get("email")

    missing = [
        field for field, value in
        [("concept", concept), ("genre", genre), ("email", email)]
        if not value
    ]
    if missing:
        return jsonify({"error": f"Missing required fields: {', '.join(missing)}"}), 400

    character_name = random.choice(CHARACTER_NAMES)
    print(f"Protagonist: {character_name}")

    try:
        generator = StoryGenerator()

        story = generator.generate_story(concept, genre, character_name)
        title = generator.generate_title(story)
        mcqs = generator.generate_mcqs(story, concept)

        questions, options_list, correct_answers, hints_list = generator.parse_mcqs(mcqs)

    except Exception as e:
        print(f"Generation failed: {e}")
        return jsonify({"error": f"Story generation failed: {str(e)}"}), 502

    try:
        db.collection("stories").add({
            "title": title,
            "story": story,
            "mcqs": mcqs,
            "hints": hints_list,
            "concept": concept,
            "genre": genre,
            "language": LANGUAGE,
            "email": email,
            "character_name": character_name,
            "model": MODEL_NAME,
            "created_at": firestore.SERVER_TIMESTAMP,
        })
    except Exception as e:
        print(f"Firestore write failed: {e}")

    elapsed = round(time.time() - started, 1)
    print(f"Completed in {elapsed}s")

    return jsonify({
        "message": "Story and MCQs generated successfully",
        "title": title,
        "story": story,
        "mcqs": mcqs,
        "hints": hints_list,
        "questions": questions,
        "options": options_list,
        "correct_answers": correct_answers,
        "generation_time_seconds": elapsed,
    }), 200


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
