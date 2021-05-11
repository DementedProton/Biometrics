import jsonpickle

class Minutia:
    """
    Minutia data

    x: int
    y: int
    orientation: int
    """

    def __init__(self, x: int, y: int, orientation: int) -> None:
        self.x = x
        self.y = y
        self.orientation = orientation

    def __repr__(self) -> str:
        return jsonpickle.encode(self, unpicklable=False)

class Delta:
    """
    Minutia data

    x: int
    y: int
    """

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

    def __repr__(self) -> str:
        return jsonpickle.encode(self, unpicklable=False)

class Core:
    """
    Minutia data

    x: int
    y: int
    """

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

    def __repr__(self) -> str:
        return jsonpickle.encode(self, unpicklable=False)

class Data:
    """
    Parsed data

    minutiae: [Minutia]
    """

    def __init__(self) -> None:
        self.minutiae = []

    def __repr__(self) -> str:
        return jsonpickle.encode(self, unpicklable=False)


def parse(data: str) -> Data:
    parseddata = Data()

    lines = data.splitlines()
    while True:
        header, lines = find_header(lines)
        if header is None:
            break
        if header == 'minutiae':
            minutiae, lines = parse_minutiae(lines)
            parseddata.minutiae = minutiae
        """
        elif header == 'cores':
            cores, lines = parse_cores(lines)
            parseddata.cores = cores
        elif header == 'deltas':
            deltas, lines = parse_deltas(lines)
            parseddata.deltas = deltas
        """

    return parseddata

def find_header(lines: str) -> (str, [str]):
    for i in range(len(lines)):
        colon = lines[i].find(':')
        if colon >= 0:
            header = lines[i][0:colon]
            return header, lines[i+1:]
    return None, []

# parse minutiae from lines
# stops when encountering another header
# returns found minutiae and leftover lines
def parse_minutiae(lines: str) -> ([Minutia], [str]):
    minutiae = []
    for i in range(len(lines)):
        colon = lines[i].find(':')
        if colon >= 0:
            return minutiae, lines[i:]

        words = lines[i].split()
        minutiae.append(Minutia(
            int(words[0]),
            int(words[1]),
            int(words[2])
        ))
    return minutiae, []

def parse_cores(lines: str) -> ([Delta]):
    cores = []
    for i in range(len(lines)):
        colon = lines[i].find(':')
        if colon >= 0:
            return cores, lines[i:]

        words = lines[i].split()
        cores.append(Core(
            int(words[0]),
            int(words[1])
        ))
    return minutiae, []

def parse_deltas(lines: str) -> ([Delta]):
    deltas = []
    for i in range(len(lines)):
        colon = lines[i].find(':')
        if colon >= 0:
            return deltas, lines[i:]

        words = lines[i].split()
        deltas.append(Core(
            int(words[0]),
            int(words[1])
        ))
    return minutiae, []
