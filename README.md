🧠 Multi-Agent AI for Personalized Sleep Improvement
Powered by a Custom Feedforward Neural Network | iOS App Presentation

📱 App Overview:
Our iOS application is designed to help users improve sleep quality by combining:

Insightful analytics

Behavioral habit tracking

Social motivation through group challenges

It features a sleek, user-friendly interface and supports both individual self-improvement and friendly competition.

🤖 Core AI Architecture: Multi-Agent System
At the heart of the app is a multi-agent AI system, each agent trained to perform a specific role. All agents rely on a custom-built feedforward neural network—built from scratch—to analyze user behavior and make personalized recommendations.

👥 Key Agents & Their Roles
Sleep Pattern Analyzer Agent

Inputs: Sleep/wake times, movement, HRV data, sleep stages

Task: Identify disruptions and trends in sleep cycles

NN Output: Sleep quality score, circadian alignment score

Habit Tracker Agent

Inputs: Caffeine use, screen time, exercise, meals

Task: Score habits based on impact on sleep

NN Output: Personalized habit feedback, risk detection

Recommendation Agent

Inputs: Insights from Analyzer and Tracker agents

Task: Suggest new habits, bedtime routines, or wind-down techniques

NN Output: Daily tip + actionable suggestions

Social Motivation Agent

Inputs: Group activity, user rankings, badges

Task: Generate challenges and promote healthy competition

NN Output: Group progress, leaderboard notifications

🧩 Feedforward Neural Network (FNN) – From Scratch
Each agent relies on an FNN architecture you built manually:

Input Layer: Encodes user features (numerical + categorical)

Hidden Layers: Process correlations between sleep factors and user context

Output Layer: Returns specific insights (e.g., a sleep score or recommendation)

Your network supports:

Backpropagation

Custom activation functions

Gradient updates

This architecture allows for:
✅ Rapid iteration
✅ On-device learning (privacy-friendly)
✅ Fine-tuned model compression for iOS performance

🎯 Personalization with Intelligence
Unlike generic sleep apps, your system learns uniquely from each user, providing:

Tailored feedback rather than canned advice

Adaptive responses based on lifestyle evolution

Weekly trend summaries and real-time nudges

🌐 Social + Competitive Elements
Users can:

Join family or friend groups

Compete for better sleep scores

Track improvement streaks

This gamification is monitored by the Social Motivation Agent, encouraging sustained engagement.

🧪 Features (Optional Add-ons):
Integration with Apple Watch or wearables

🚀 Why This Matters
In a world where sleep deprivation is rising, your app bridges neuroscience, AI, and behavioral health—powered by a transparent and intelligent custom-built system, offering meaningful, individualized change.

------------------------------------------------------------------------------------

weights(1).npz -> Fitness Watch Compatible
weights(2).npz -> Raw Metric Data(Excludes fitness watch compatability)

Expected Survey Output: 
mock_data = {
        "uuid": uuid,
        "username": username,
        "height": 170,
        "weight": 70,
        "age": 30,
        "gender": "Female",
        "day": today,
        "sleep_quality": 5,
        "bedtime": "22:30",
        "waketime": "06:30",
        "steps": 8000,
        "activity_level": 60,
        "disorders": "None",
        "stress": 4,
        "bmi": "Normal",
        "h_rate": 65,
        "goal": "Improve sleep",
        "growth_rate": "2 weeks",
        "sleep_duration": 7,
        "group_id": "group-xyz",
        "habits": "{}"
    }

0 uuid | 1 username | 2 height | 3 weight | 4 age | 5 gender | 6 day | 7 sleep_quality | 8 steps | 9 activity_level | 10 disorders | 11 stress | 12 bmi | 13 h_rate | 14 goal | 15 growth_rate | 16 sleep_duration | 17 group_id | 18 habits 