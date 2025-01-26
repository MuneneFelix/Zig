#!/bin/bash

# Create main directory structure
mkdir -p docs/database/{concepts,implementation,exercises}

# Create concept documentation files
cd docs/database/concepts
touch 01_storage_engine.md
touch 02_buffer_management.md
touch 03_btree_indexing.md
touch 04_transactions.md
touch 05_query_processing.md

# Create implementation documentation files
cd ../implementation
touch 01_page_layout.md
touch 02_memory_manager.md
touch 03_index_structures.md
touch 04_wal.md
touch 05_query_engine.md

# Create exercise files
cd ../exercises
touch 01_storage_exercises.md
touch 02_indexing_exercises.md
touch 03_transaction_exercises.md

# Create root documentation files
cd ..
touch LEARNING_PATH.md
touch GLOSSARY.md
touch PROGRESS.md 