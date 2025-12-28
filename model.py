from transformers import AutoProcessor, Gemma3ForConditionalGeneration
import torch
import sys

MODEL_ID = "./gemma-3-4b-it"  # move this to module level so connect() can see it

class ChatGemma:
    def __init__(self):
        self.model = None
        self.processor = None
    
    def connect(self, model_id: str):
        print("Loading model...")
        self.model = Gemma3ForConditionalGeneration.from_pretrained(
            model_id,
            dtype=torch.bfloat16,          # torch_dtype is deprecated alias
            device_map="auto",
        ).eval()

        self.processor = AutoProcessor.from_pretrained(model_id)
        return "connection established"

    def chat_gemma(self, user_message: str, system_prompt: str = "You are a helpful assistant.") -> str:
        messages = [
            {
                "role": "system",
                "content": [{"type": "text", "text": system_prompt}],
            },
            {
                "role": "user",
                "content": [{"type": "text", "text": user_message}],
            },
        ]

        inputs = self.processor.apply_chat_template(
            messages,
            add_generation_prompt=True,
            tokenize=True,
            return_tensors="pt",
        ).to(self.model.device)

        with torch.inference_mode():
            output = self.model.generate(
                inputs,
                max_new_tokens=256,
                do_sample=False,
                pad_token_id=self.processor.tokenizer.eos_token_id,
            )

        generated = output[0][inputs.shape[-1]:]
        return self.processor.decode(generated, skip_special_tokens=True)


if __name__ == "__main__":
    # 1) create the object
    client = ChatGemma()
    # 2) connect (loads model into client.model)
    status = client.connect(MODEL_ID)
    print(f"client status: {status}")
    print(f"what is sys.argv: {sys.argv}")

    # 3) use client for inference
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
        print("You:", prompt)
        ans = client.chat_gemma(prompt)
        print("\nGemma:", ans, "\n")
    else:
        print("No payload provided. Starting interactive mode...")
        while True:
            q = input("You: ")
            if not q.strip():
                break
            ans = client.chat_gemma(q)
            print("\nGemma:", ans, "\n")
