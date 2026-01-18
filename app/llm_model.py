import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain_huggingface import HuggingFacePipeline

class GemmaChat:
    """Chatbot using local Gemma 3 model with LangChain."""
    def __init__(self, model_path: str):
        self.model_path = model_path
        
        # 1. Device Selection
        if torch.cuda.is_available():
            self.device = "cuda"
        elif torch.backends.mps.is_available():
            self.device = "mps"
        else:
            self.device = "cpu"
            
        self.llm = None
        self.history = []
        self.load_model()
        
    def load_model(self):
        """Load model and set up LangChain."""
        print(f"Loading Gemma 3 from {self.model_path}...")

        # 2. Precision Selection (bfloat16 is preferred for Gemma 3)
        dt = torch.bfloat16 if self.device in ["cuda", "mps"] else torch.float32

        tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        
        # 3. Model Loading
        model = AutoModelForCausalLM.from_pretrained(
            self.model_path,
            torch_dtype=dt,
            low_cpu_mem_usage=True,
            device_map="auto" # LangChain works best when transformers handles the map
        )
        
        # Create pipeline
        pipe = pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            max_new_tokens=1024,
            temperature=0.7,
            return_full_text=False 
        )
        
        self.llm = HuggingFacePipeline(pipeline=pipe)
        print(f"Ready on {self.device}!\n")
    
    def chat(self, message: str) -> str:
        """Send a message using Gemma 3 specific chat template."""
        
        # Build context using Gemma 3 turn tags
        context = ""
        for human_msg, bot_msg in self.history[-3:]:
            context += f"<start_of_turn>user\n{human_msg}<end_of_turn>\n"
            context += f"<start_of_turn>model\n{bot_msg}<end_of_turn>\n"
            
        # Final Prompt Construction
        prompt = f"{context}<start_of_turn>user\n{message}<end_of_turn>\n<start_of_turn>model\n"
        
        response = self.llm.invoke(prompt)
        
        # Gemma 3 responses are clean with return_full_text=False, 
        # but we strip just in case.
        clean_response = response.strip()

        self.history.append((message, clean_response))
        return clean_response
    
    def clear_history(self):
        self.history = []
        print("History cleared.\n")
    
    def run(self):
        print("Gemma 3 Chatbot (type 'exit' to quit, 'clear' to clear history)\n")
        while True:
            user_input = input("You: ").strip()
            if user_input.lower() in ['exit', 'quit']:
                break
            if user_input.lower() == 'clear':
                self.clear_history()
                continue
            if user_input:
                response = self.chat(user_input)
                print(f"Bot: {response}\n")

if __name__ == "__main__":
    PATH_TO_MODEL = "./model/gemma-3-4b-it" 
    chatbot = GemmaChat(model_path=PATH_TO_MODEL) 
    chatbot.run()