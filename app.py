import os
import gradio as gr
import mlflow
from openai import OpenAI
import time

# Configuración de MLflow
MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000")
mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

EXPERIMENT_NAME = "traductor-genai"
mlflow.set_experiment(EXPERIMENT_NAME)

api_key = os.getenv("API_KEY")
client = OpenAI(api_key=api_key) if api_key else None

def translate_text(text, target_language):
    if not text:
        return "Por favor ingresa un texto."
    
    if not client:
        return "Error: API_KEY no configurada."

    start_time = time.time()
    
    system_prompt = f"Eres un traductor experto. Traduce el siguiente texto al {target_language}."
    
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text}
            ],
            temperature=0.3
        )
        
        translation = response.choices[0].message.content.strip()
        end_time = time.time()
        latency = end_time - start_time
        
        with mlflow.start_run():
            mlflow.log_param("target_language", target_language)
            mlflow.log_param("model", "gpt-4o")
            mlflow.log_param("input_length", len(text))
            
            mlflow.log_metric("latency", latency)
            
            mlflow.log_text(text, "original_text.txt")
            mlflow.log_text(translation, "translation.txt")
            
            mlflow.set_tag("app", "gradio-translator")

        return translation
        
    except Exception as e:
        return f"Error durante la traducción: {str(e)}"

with gr.Blocks(title="Traductor AI Orquestado") as demo:
    gr.Markdown("# Traductor Gen-AI con MLflow Tracking")
    
    with gr.Row():
        input_text = gr.Textbox(label="Texto original", placeholder="Escribe aquí...", lines=4)
        output_text = gr.Textbox(label="Traducción", interactive=False, lines=4)
    
    with gr.Row():
        language_dropdown = gr.Dropdown(
            choices=["Inglés", "Francés", "Alemán", "Italiano", "Portugués", "Japonés"], 
            value="Inglés", 
            label="Idioma destino"
        )
        translate_btn = gr.Button("Traducir", variant="primary")
    
    translate_btn.click(
        fn=translate_text, 
        inputs=[input_text, language_dropdown], 
        outputs=output_text
    )

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)

