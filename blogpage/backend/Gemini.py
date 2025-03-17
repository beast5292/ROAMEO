import google.generativeai as genai

genai.configure(api_key="AIzaSyCKmuBctSMoriGSx_-sIvl5UJibbkQnNCE")

model = genai.GenerativeModel("gemini-1.5-pro")  # Use an available model
response = model.generate_content("Explain how AI works")

print(response.text)

