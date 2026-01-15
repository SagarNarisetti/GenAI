
from langchain_huggingface import HuggingFacePipeline
from langchain_core.prompts import ChatPromptTemplate
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import torch


class GemmaChat:
    """ chatbot using local Gemma model with LangChain."""
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.llm = None
        self.history = []
        self._initialize()
        if torch.cuda.is_available():
            self.device = "cuda"
        elif torch.backends.mps.is_available():
            self.device = "mps"  
        else:
            self.device = "cpu"
    
    def _initialize(self):
        """Load model and set up LangChain."""
        print(f"Loading model from {self.model_path}...")
        # Load model
        tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        dtype = torch.float16 if self.device in ["cuda", "mps"] else torch.float32
        model = AutoModelForCausalLM.from_pretrained(
            self.model_path,
            dtype=dtype,
            low_cpu_mem_usage=True, # "auto" works for MPS in recent versions of Accelerate/Transformers
            device_map={"": self.device} if self.device == "mps" else "auto"
            )
        
        actual_device = next(model.parameters()).device
        # Create pipeline
        pipe = pipeline(
            "text-generation",
            model=model,
            tokenizer=tokenizer,
            max_new_tokens=512,
            temperature=0.7
        )
        # LangChain LLM
        self.llm = HuggingFacePipeline(pipeline=pipe)
        print(f"Device set to use: {actual_device}")
        print(f"Ready on {self.device}!\n")
    
    def chat(self, message: str) -> str:
        """Send a message and get response."""
        context = ""
        for human_msg, bot_msg in self.history:
            context = context + f"Human: {human_msg}\nAssistant: {bot_msg}\n\n"
        prompt = f"""
        You are a helpful AI assistant.
        {context} Human: {message}
        Assistant:
        """                           
        #response
        response = self.llm.invoke(prompt)
        # Store in history
        self.history.append((message, response))
        return response
    
    def clear_history(self):
        """Clear conversation history."""
        self.history = []
        print("History cleared.\n")
    
    def run(self):
        """Start interactive chat."""
        print("Gemma Chatbot (type 'exit' to quit, 'clear' to clear history)\n")
        while True:
            user_input = input("You: ").strip()
            if user_input.lower() in ['exit', 'quit']:
                print("Goodbye!")
                break
            if user_input.lower() == 'clear':
                self.clear_history()
                continue
            if user_input:
                response = self.chat(user_input)
                print(f"Bot: {response}\n")

if __name__ == "__main__":
    chatbot = GemmaChat(model_path="./model/gemma-3-4b-it")
    chatbot.run()