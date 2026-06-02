import mido
import typer
import csv

result = []

def main(relative_path: str, target_bpm: int):
    midi = mido.MidiFile(relative_path)
 
    current_tick = 0
    ratio = 60 / target_bpm
    
    for message in midi:
        current_tick += message.time * 96 * 2
        if message.type == "note_on":
            absolute_time_in_seconds = (current_tick / 96) * (ratio)
            note = message.note
            
            result.append([absolute_time_in_seconds, note])
            
    with open("result.csv", 'w', newline="\n") as csv_file:
        csv_writer = csv.writer(csv_file, delimiter=",")
        csv_writer.writerows(result)
        

if __name__ == "__main__":
    typer.run(main)