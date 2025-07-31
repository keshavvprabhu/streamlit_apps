import os
from pypdf import PdfWriter
import glob
from loguru import logger 

def merge_pdf_files(input_folder_path, output_file_path)
"""
  Merges all PDF files in the specified folder into a single PDF file.

  :param folder_path: Path to the folder containing PDF files.
  :param output_file_path: Path where the merged PDF will be saved.
"""

    folder_path = os.path.abspath(input_folder_path)  # Normalize the path
    output_file_path = os.path.abspath(output_file_path)  # Name of the output file


    with PdfWriter() as merger:
        for file in glob.glob(os.path.join(folder_path, '*.pdf')):
            logger.info(f"Adding {os.path.join(folder_path, pdf)}  -  {os.path.exists(os.path.join(folder_path, pdf))} to the merger.")
            merger.append(os.path.join(folder_path, pdf))

        merger.write(output_file_path)
        logger.info(f"Merged PDF saved to {output_file_path}")