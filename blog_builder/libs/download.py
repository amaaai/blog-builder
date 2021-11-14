"""SSL / Download related stuff"""
from nltk import download
import ssl

def download_punkt():
    """Wrapper to download punkt."""
    try:
        _create_unverified_https_context = ssl._create_unverified_context
    except AttributeError:
        pass
    else:
        ssl._create_default_https_context = _create_unverified_https_context
    download('punkt')
