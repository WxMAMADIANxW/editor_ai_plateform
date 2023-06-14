FROM continuumio/miniconda3

# Install git
RUN apt-get update && apt-get install -y git

# Create the environment:
COPY environment.yml .
RUN conda env create -f environment.yml

# Clone a repo
# TODO: Not done yet, check reminders
RUN git clone https://github.com/jayleicn/moment_detr.git

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "moment_detr", "PYTHONPATH=$PYTHONPATH:.", "python", "run_on_video/run.py"]
