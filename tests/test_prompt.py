import unittest
from src.advice.geminiAPI import PromptPlan

class TestPromptPlan(unittest.TestCase):
    def test_generate_advice_returns_dict(self):
        # Act: Actually call the Gemini API
        plan = PromptPlan(
            username="testuser",
            user_stats="age: 25, gender: female, sleep: 6h",
            critical_factors="Stress Level",
            goal="improve sleep quality",
            progress_speed="2 weeks"
        )
        result = plan.generate_advice()

        # Assert
        self.assertIsInstance(result, dict)
        self.assertTrue(len(result) > 0)  # Ensure the dict is not empty

if __name__ == "__main__":
    unittest.main()
# PYTHONPATH=. python -m unittest tests/test_prompt.py
