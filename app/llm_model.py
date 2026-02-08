import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain_huggingface import HuggingFacePipeline
from typing import List, Optional, Any
from pathlib import Path
from langchain_core.prompts import PromptTemplate, ChatPromptTemplate
from langchain_classic.chains import LLMChain
from langchain_core.output_parsers import StrOutputParser

import logging
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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
    


class GemmaLLM:    
    def __init__(self, model_path: str, temperature: float = 0.7, max_new_tokens: int = 512, device: str = "auto"):
        
        self.model_path = model_path
        self.temperature = temperature
        self.max_new_tokens = max_new_tokens
        self.history = []
        
        # Determine device
        if device == "auto":
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            self.device = device
        
        logger.info(f"🔄 Loading model from {model_path}")
        logger.info(f"📱 Using device: {self.device}")
        
        try:
            # Load tokenizer
            # The tokenizer converts text to numbers (tokens) the model understands
            self.tokenizer = AutoTokenizer.from_pretrained(
                model_path,
                local_files_only=True,  # Only use local files, no downloading
                trust_remote_code=True
            )
            
            # Set padding token if not set
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            logger.info("✅ Tokenizer loaded")
            
            # Load model
            # This is the actual neural network with billions of parameters
            self.model = AutoModelForCausalLM.from_pretrained(
                model_path,
                local_files_only=True,
                torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
                device_map=self.device if self.device == "cuda" else None,
                trust_remote_code=True,
                low_cpu_mem_usage=True
            )
            
            # Move to device if CPU
            if self.device == "cpu":
                self.model = self.model.to(self.device)
            
            logger.info("✅ Model loaded into memory")
            
            # Create text generation pipeline
            # This wraps the model with convenient methods for generation
            self.pipe = pipeline(
                "text-generation",
                model=self.model,
                tokenizer=self.tokenizer,
                max_new_tokens=max_new_tokens,
                temperature=temperature,
                do_sample=True,  # Use sampling for more natural responses
                top_p=0.95,  # Nucleus sampling
                repetition_penalty=1.1  # Discourage repetition
            )
            logger.info("✅ Pipeline created")
            
            # Wrap in Langchain for easy integration
            self.llm = HuggingFacePipeline(pipeline=self.pipe)
            logger.info("✅ LLM ready for use")
            
        except Exception as e:
            logger.error(f"❌ Failed to initialize LLM: {e}")
            raise
    
    def _format_prompt(self, query: str) -> str:
        """
        Format prompt according to Gemma's chat template.
        """
        context = ""
        for human_msg, bot_msg in self.history[-3:]:
            context = context + f"<start_of_turn>user\n{human_msg}<end_of_turn>\n"
            context = context + f"<start_of_turn>model\n{bot_msg}<end_of_turn>\n"
            
        # Final Prompt Construction
        prompt = f"{context}<start_of_turn>user\n{query}<end_of_turn>\n<start_of_turn>model\n"
        
        response = self.llm.invoke(prompt)
        
        clean_response = response.strip()

        self.history.append((query, clean_response))
        # Gemma-2 chat format
        return f"{context}<start_of_turn>user\n{query}<end_of_turn>\n<start_of_turn>model\n"
    
    def _clean_response(self, response: str, prompt: str) -> str:
        """
        Remove prompt echo and special tokens from response.
        """
        # Remove the prompt if it's echoed
        if prompt and response.startswith(prompt):
            response = response[len(prompt):]
        
        # Remove special tokens
        response = response.replace("<end_of_turn>", "")
        response = response.replace("<start_of_turn>", "")
        response = response.replace("<bos>", "")
        response = response.replace("<eos>", "")
        
        # Strip whitespace
        response = response.strip()
        
        return response

    def generate_response(self, query: str) -> str:

        """ Generate a response from the model based on the input query."""

        try:
            # Format the prompt (Gemma models have specific formatting requirements)
            formatted_prompt = self._format_prompt(query)
            
            # Generate response
            response = self.llm.invoke(input=formatted_prompt)
            
            # Extract just the generated text (remove the prompt)
            clean_response = self._clean_response(response, formatted_prompt)
            
            return clean_response
            
        except Exception as e:
            logger.error(f"Error generating response: {e}")
            return f"Error: {str(e)}"
    
    def generate_rag_response(self, query: str, context: str) -> str:
        """
        Generate a response using RAG (Retrieval-Augmented Generation).
        
        """
        try:
            # Create a prompt template that combines context and question
            rag_prompt = PromptTemplate(
                input_variables=["context", "question"],
                template="""
                Use the following context to answer the question. If you cannot answer based on the context, say so.
                Context: {context}
                
                Question: {question}

                Answer:
                """)
            
            # Create a chain that combines the prompt and LLM
            # chain = LLMChain(llm=self.llm, prompt=rag_prompt)
            chain = rag_prompt | self.llm | StrOutputParser()
            
            # Generate response with context
            response = chain.invoke({"context": context, "question": query})
            
            # Clean the response
            clean_response = self._clean_response(response, "")
            
            return clean_response
            
        except Exception as e:
            logger.error(f"❌ Error generating RAG response: {e}")
            return f"Error: {str(e)}"
    

    def test_connection(self) -> bool:
        """
        Test if the model is working correctly.
        
        Returns:
            True if model responds, False otherwise
        """
        try:
            test_response = self.generate_response("Hello, are you working?")
            return bool(test_response) and "error" not in test_response.lower()
        except Exception:
            return False
    
    def get_model_info(self) -> dict:
        """
        Get information about the loaded model.
        
        Returns:
            Dictionary with model metadata
        """
        return {
            "model_path": self.model_path,
            "device": self.device,
            "temperature": self.temperature,
            "max_new_tokens": self.max_new_tokens,
            "model_type": self.model.config.model_type if hasattr(self.model, 'config') else "unknown",
            "vocab_size": self.tokenizer.vocab_size if self.tokenizer else 0
        }


    

if __name__ == "__main__":
    # model_path = os.getenv("MODEL_PATH")
    # full_path = str(Path(model_path).resolve())
    # chatbot = GemmaChat(model_path=full_path)
    # output = chatbot._call("Hello, what is the species of animal Royya ?")
    # print(output)
    # # chatbot.run()

    ########################################################################

    print("🔧 Testing Gemma3 LLM from HuggingFace...")
    
    # Set your model path (update this to your actual path)
    MODEL_PATH = os.getenv("MODEL_PATH", "./model/gemma-3-4b-it")
    
    if not os.path.exists(MODEL_PATH):
        print(f"❌ Model not found at {MODEL_PATH}")
        print("Please download the model from HuggingFace first!")
        print("\nTo download:")
        print("  huggingface-cli download google/gemma-2-2b-it --local-dir ./models/gemma-2-2b-it")
        exit(1)
    
    # Initialize the model
    print("\n📥 Loading model (this takes 30-60 seconds)...")
    gemma = GemmaLLM(model_path=MODEL_PATH)
    
    # Print model info
    print("\n📊 Model Information:")
    for key, value in gemma.get_model_info().items():
        print(f"  {key}: {value}")
    
    # Test basic generation
    print("\n📝 Basic Generation Test:")
    response = gemma.generate_response("What is machine learning in one sentence?")
    print(f"Response: {response}")
    
    # Test RAG generation
    print("\n📚 RAG Generation Test:")
    sample_context = "Machine learning is a subset of artificial intelligence that enables systems to learn and improve from experience without being explicitly programmed."
    rag_response = gemma.generate_rag_response(
        query="What is machine learning?",
        context=sample_context
    )
    print(f"RAG Response: {rag_response}")
    
    print("\n✅ All tests completed!")


