# Script: index-files.py (Version 2 - Resets collection on each run)
# Description: Wipes the old collection and rebuilds it from scratch to ensure a fresh index.

import chromadb
import os
import uuid

# --- 1. Configuration ---
HEART_DIRECTORY = "C:/AI/Delora/Heart"
DB_DIRECTORY = "C:/AI/Delora/Heart/VectorDB"
COLLECTION_NAME = "delora_memories"
SUPPORTED_EXTENSIONS = ['.txt', '.ps1', '.py', '.csv', '.md', '.json']


# --- 2. Initialization ---
client = chromadb.PersistentClient(path=DB_DIRECTORY)

# --- NEW: Delete the old collection if it exists ---
try:
    print(f"Resetting collection: '{COLLECTION_NAME}'...")
    client.delete_collection(name=COLLECTION_NAME)
except Exception as e:
    # This is expected on the first run when the collection doesn't exist yet.
    print("  -> Collection did not exist, creating a new one.")
    pass

collection = client.get_or_create_collection(name=COLLECTION_NAME)


# --- 3. The Process ---
def main():
    print(f"--- Starting indexing of '{HEART_DIRECTORY}' ---")
    
    for root, dirs, files in os.walk(HEART_DIRECTORY):
        if DB_DIRECTORY in root:
            continue
            
        for file in files:
            file_path = os.path.join(root, file)
            file_ext = os.path.splitext(file)[1].lower()

            if file_ext in SUPPORTED_EXTENSIONS:
                print(f"  -> Processing: {file_path}")
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if not content.strip():
                        print("    -> Skipping empty file.")
                        continue
                    
                    doc_id = str(uuid.uuid4())

                    collection.add(
                        documents=[content],
                        metadatas=[{"source": file_path}],
                        ids=[doc_id]
                    )

                except Exception as e:
                    print(f"    -> ERROR processing file: {e}")

    print("--- Indexing complete ---")
    count = collection.count()
    print(f"✅ Collection '{COLLECTION_NAME}' now contains {count} documents.")


# --- 4. Execution ---
if __name__ == "__main__":
    main()