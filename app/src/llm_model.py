import os
import logging
from dotenv import load_dotenv

# LangChain and AWS Bedrock integrations
from langchain_aws import ChatBedrockConverse
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class LLMBase:
    def __init__(
        self,
        model_id: str = "google.gemma-4-12b-it",  
        region_name: str = "us-west-1",
        temperature: float = 0.7,
        max_new_tokens: int = 512,
        SYSTEM_MESSAGE: str = "You are a helpful assistant.",
        CONSTRAINTS: str = (
            "1. If the answer is not contained within the context below, state clearly that you do not have enough information.\n"
            "2. Do not use outside knowledge or make up facts.\n"
            "3. Keep your response concise and professional."
        ),
    ):
        # Configuration setup
        self.model_id = model_id
        self.region_name = region_name
        self.temperature = temperature
        self.max_new_tokens = max_new_tokens
        self.system_message = SYSTEM_MESSAGE
        self.constraints = CONSTRAINTS
        self.history = []

        logger.info(f"Targeting AWS Bedrock Model ID: {self.model_id}")
        logger.info(f"Using AWS Region: {self.region_name}")

        try:
            logger.info("Initializing LangChain Bedrock Converse client...")
            
            # Step 1: Initialize connection through ChatBedrockConverse
            # This replaces local torch/transformers pipelines completely
            self.llm = ChatBedrockConverse(
                model_id=self.model_id,
                region_name=self.region_name,
                temperature=self.temperature,
                max_tokens=self.max_new_tokens,
                # Additional Bedrock configurations can go here
            )
            logger.info("AWS Bedrock client initialized successfully")

        except Exception as e:
            logger.error(f"Failed to initialize Bedrock LLM: {e}")
            raise

    def _format_prompt(self, query: str) -> str:
        """
        Format prompt tracking chat history for the standalone inference step.
        """
        context = ""
        # Keep track of the last 3 conversation turns
        for human_msg, bot_msg in self.history[-3:]:
            context += f"User: {human_msg}\nAssistant: {bot_msg}\n"

        # Final Prompt Construction for simple conversational generation
        full_prompt = f"{context}User: {query}\nAssistant:"
        return full_prompt

    def generate_response(self, query: str) -> str:
        """Generate a response from Bedrock based on the input query and local history."""
        try:
            formatted_prompt = self._format_prompt(query)

            # Step 2: Invoke the Bedrock LLM instance
            response = self.llm.invoke(input=formatted_prompt)
            
            # LangChain ChatBedrockConverse outputs an AIMessage object. Extract its text content.
            clean_response = response.content.strip()

            # Record turn history
            self.history.append((query, clean_response))
            return clean_response

        except Exception as e:
            logger.error(f"Error generating response: {e}")
            return f"Error: {str(e)}"

    def generate_rag_response(self, query: str, context: str) -> str:
        """
        Generate a response using RAG (Retrieval-Augmented Generation) orchestrated via Bedrock.
        """
        try:
            # Construct a prompt template structured for Bedrock parsing
            rag_prompt = PromptTemplate(
                input_variables=["system_message", "constraints", "context", "question"],
                template="""
                System Role: {system_message}

                Constraints:
                {constraints}

                Context Reference:
                {context}

                User Request:
                {question}

                Response:
                """,
            )

            # Re-build LangChain Expression Language (LCEL) chain targeting Bedrock
            chain = rag_prompt | self.llm | StrOutputParser()

            # Invoke chain execution via AWS Bedrock 
            response = chain.invoke({
                "system_message": self.system_message, 
                "constraints": self.constraints, 
                "context": context, 
                "question": query
            })

            return response.strip()

        except Exception as e:
            logger.error(f"❌ Error generating RAG response: {e}")
            return f"Error: {str(e)}"

    def test_connection(self) -> bool:
        """
        Test if the connection to AWS Bedrock and model allocation is healthy.
        """
        try:
            test_response = self.generate_response("Hello, are you working?")
            return bool(test_response) and "error" not in test_response.lower()
        except Exception:
            return False

    def get_model_info(self) -> dict:
        """Get structural runtime information about the connected Bedrock client."""
        return {
            "model_id": self.model_id,
            "region": self.region_name,
            "temperature": self.temperature,
            "max_new_tokens": self.max_new_tokens,
            "current_history_length": len(self.history),
            "backend": "AWS Bedrock (Serverless)"
        }


if __name__ == "__main__":
    print("🔧 Initializing LLM Connection via Amazon Bedrock...")
    
    # Instantiate the new class structure
    # Make sure you have setup your AWS credentials in your environment or ~/.aws/credentials
    llm_assistant = LLMBase(
        model_id="google.gemma-4-12b-it",  # Replace with target active Gemma model ID on Bedrock
        region_name="us-west-1"
    )

    # 1. Test Base Model Connection
    print("\n--- Testing Direct Generation ---")
    reply = llm_assistant.generate_response("What is ECR in AWS?")
    print(f"Reply:\n{reply}")

    # 2. Test RAG Chain Processing 
    print("\n--- Testing RAG Chain Execution ---")
    sample_context = "ECR is an automated container registry tool. It stores, manages, and deploys Docker images."
    sample_query = "What does ECR do with Docker images?"
    
    rag_reply = llm_assistant.generate_rag_response(query=sample_query, context=sample_context)
    print(f"RAG Reply:\n{rag_reply}")
