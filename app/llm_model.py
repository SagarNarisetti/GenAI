import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain_huggingface import HuggingFacePipeline
from typing import List, Optional, Any
from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

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

        self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        
        # 3. Model Loading
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_path,
            torch_dtype=dt,
            low_cpu_mem_usage=True,
            device_map="auto" # LangChain works best when transformers handles the map
        )
        
        # Create pipeline
        pipe = pipeline(
            "text-generation",
            model=self.model,
            tokenizer=self.tokenizer,
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
    def _call(self, prompt: str, stop: Optional[List[str]] = None, **kwargs) -> str:
        """Generate response from Gemma 3"""
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.model.generate(
            **inputs,
            max_new_tokens=512,
            temperature=0.7,
            top_p=0.9,
            do_sample=True,
            pad_token_id=self.tokenizer.eos_token_id
        )
        
        response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        # Remove the prompt from response
        response = response[len(prompt):].strip()
        
        return response

if __name__ == "__main__":
    model_path = os.getenv("MODEL_PATH")
    full_path = str(Path(model_path).resolve())
    chatbot = GemmaChat(model_path=full_path)
    output = chatbot._call("Hello, what is the species of animal Royya ?")
    print(output)
    # chatbot.run()