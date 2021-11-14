"""Helpers to chunk text"""

from nltk.tokenize import sent_tokenize

from typing import List


def chunk_it(sentences: List[str], tokenizer) -> List[str]:
    length, chunk, chunks, count = 0, "", [], -1  # initialize variables
    for sentence in sentences:
        count += 1
        combined_length = (
            len(tokenizer.tokenize(sentence)) + length
        )  # add the no. of sentence tokens to the length counter

        if combined_length <= tokenizer.max_len_single_sentence:  # if it doesn't exceed
            chunk, length, chunks = smaller_than_length(sentence, combined_length, chunk, chunks, count, sentences)
        else:
            chunk, length, chunks = bigger_than_length(sentence, chunk, chunks, tokenizer)
    return chunks


def bigger_than_length(sentence, chunk, chunks, tokenizer):
    """Add the sentence to the chunk, update the length counter
    and if it's the last sentance append to the chunks to save."""
    chunks.append(chunk)  # save the chunk
    chunk = sentence + " "
    length = len(tokenizer.tokenize(sentence))
    return chunk, length, chunks


def smaller_than_length(sentence, combined_length, chunk, chunks, count, sentences):
    """Add the sentence to the chunk, update the length counter
    and if it's the last sentance append to the chunks to save."""

    chunk += f"{sentence} "
    length = combined_length
    if count == len(sentences) - 1:  # if it is the last sentence, save
        chunks.append(chunk)
    return chunk, length, chunks


def chunk_tokenize_sentence(text, tokenizer):
    sentences = sent_tokenize(text)
    chunks = chunk_it(sentences, tokenizer)
    return [tokenizer(chunk, return_tensors="pt") for chunk in chunks]
