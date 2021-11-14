from blog_builder.libs.chunk import chunk_tokenize_sentence
from blog_builder.libs.download import download_punkt
from blog_builder.libs.io import read_files
from blog_builder.models import decode, get_model, get_tokenizer, predict
from blog_builder.models import set_config

from pathlib import Path

_FILE_LOC = "resources"


download_punkt()

def summarize():
    model = get_model()
    tokenizer = get_tokenizer()
    print(model.config.task_specific_params["summarization"]["min_length"])
    set_config(model)
    print(model.config.task_specific_params["summarization"]["min_length"])
    posts = read_files(Path(_FILE_LOC))
    for _, text in posts.items():
        inputs = chunk_tokenize_sentence(text, tokenizer)
        outputs = predict(inputs, model)
        decoded = decode(outputs, tokenizer)
        print(decoded)


if __name__ == "__main__":
    summarize()
