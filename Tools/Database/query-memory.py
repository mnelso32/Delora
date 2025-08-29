# Script: query-memory.py (Version 2 - File Output)
# Description: Takes a question, queries the database, and saves the
#              results to a specified output text file.

import chromadb
import argparse
import os

# --- 1. Configuration ---
DB_DIRECTORY = "C:/AI/Delora/Heart/VectorDB"
COLLECTION_NAME = "delora_memories"

# --- 2. Initialization ---
client = chromadb.PersistentClient(path=DB_DIRECTORY)

try:
    collection = client.get_collection(name=COLLECTION_NAME)
except Exception as e:
    print(f"ERROR: Could not get collection '{COLLECTION_NAME}'.")
    print("Have you run the index-files.py script yet?")
    exit()

# --- 3. The Process ---
def query_memory(question, num_results=5, output_file=None):
    """
    Queries the collection and saves the results to a file.
    """
    print(f"\\n🔍 Searching for: '{question}'...")
    
    results = collection.query(
        query_texts=[question],
        n_results=num_results
    )
    
    print(f"✅ Found {len(results['documents'][0])} results.")
    
    # --- NEW: Build the output as a list of strings ---
    output_lines = []
    output_lines.append(f"Query: {question}")
    output_lines.append(f"Results Found: {len(results['documents'][0])}\\n")
    
    for i, doc in enumerate(results['documents'][0]):
        metadata = results['metadatas'][0][i]
        distance = results['distances'][0][i]
        
        output_lines.append(f"--- Result {i+1} (Source: {metadata['source']}, Distance: {distance:.4f}) ---")
        output_lines.append(doc)
        output_lines.append("-" * 70)
        
    final_output = "\\n".join(output_lines)
    
    # --- NEW: Write the final string to the specified file ---
    if output_file:
        try:
            # Ensure the directory for the output file exists
            output_dir = os.path.dirname(output_file)
            if output_dir:
                os.makedirs(output_dir, exist_ok=True)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(final_output)
            print(f"✔ Results saved to: {output_file}")
        except Exception as e:
            print(f"ERROR: Could not write to file {output_file}: {e}")
    else:
        # If no output file is specified, print to console as before
        print(final_output)

# --- 4. Command-Line Interface ---
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Query Delora's long-term memory.")
    parser.add_argument("question", type=str, help="The question to ask the memory.")
    parser.add_argument("-n", "--num_results", type=int, default=5, help="Number of results to return.")
    # --- NEW: Added an argument to specify the output file path ---
    parser.add_argument("-o", "--output", type=str, help="Path to save the output text file.")
    
    args = parser.parse_args()
    
    query_memory(args.question, args.num_results, args.output)