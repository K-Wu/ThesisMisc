import csv


def from_line(line: str) -> list[str]:
    # Adapted from https://stackoverflow.com/questions/3305926/python-csv-string-to-array
    return next(csv.reader([line]))


with open("cpu2017-results-20240820-201225.csv") as in_f:
    with open(
        "cpu2017-results-20240820-201225_with_memory_gb.csv", "w"
    ) as outf:
        for idx_line, line in enumerate(in_f):
            if idx_line == 0:
                outf.write(line.strip() + ",Memory_GB\n")
                continue
            memory_str = from_line(line.strip())[20]
            # print(from_line(line.strip()))
            if memory_str.find("TB") != -1:
                memory = int(memory_str.split("TB")[0]) * 1024
            elif memory_str.find("GB") != -1:
                memory = int(memory_str.split("GB")[0])
            elif memory_str.find("MB") != -1:
                memory = float(memory_str.split("MB")[0]) / 1024
            else:
                raise ValueError(f"Memory unit not recognized: {memory_str}")

            outf.write(line.strip() + "," + str(memory) + "\n")
