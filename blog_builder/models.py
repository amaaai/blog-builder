from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from typing import List, Any


_PRETRAINED_MODEL = "sshleifer/distilbart-cnn-12-6"


def get_model(pretrained_model: str = _PRETRAINED_MODEL) -> AutoModelForSeq2SeqLM:
    """Returns the summarization model"""
    return AutoModelForSeq2SeqLM.from_pretrained(pretrained_model)


def get_tokenizer(pretrained_model: str = _PRETRAINED_MODEL) -> AutoTokenizer:
    """Returns the tokenizer"""
    return AutoTokenizer.from_pretrained(pretrained_model)


def set_config(model: AutoModelForSeq2SeqLM) -> None:
    """Set some config parameters config"""
    model.config.max_length = 1024
    model.config.min_length = 512
    model.config.task_specific_params["summarization"]["min_length"] = 512
    model.config.task_specific_params["summarization"]["max_length"] = 102


def predict(inputs: List[int], model) -> List[Any]:
    return [model.generate(**input) for input in inputs]


def decode(outputs: List[int], tokenizer):
    return [tokenizer.decode(*output, skip_special_tokens=True) for output in outputs]
