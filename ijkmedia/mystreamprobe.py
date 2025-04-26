import av
import argparse

def probe_stream(url, probesize, analyze_duration):
    options = dict()
    options['probesize'] = str(probesize)
    options['analyzeduration'] = str(analyze_duration)
    try:
        container = av.open(url, options=options)
    except Exception as e:
        print("Unable to open stream, error:")
        print(e)
        return None
    print(f"There are {len(container.streams)} streams found!")
    for idx, stream in enumerate(container.streams):
        print(f"Stream[{idx}] type: {stream.type}, codec: {stream.codec.name}")
    container.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Probe a stream")
    parser.add_argument("--url", type=str, required=True, help="URL of the stream")
    parser.add_argument("--probesize", type=int, default=5*1024*1024, help="Probe size in bytes")
    parser.add_argument("--analyzeduration", type=int, default=5*1000*1000, help="Analyze duration in microseconds")
    args = parser.parse_args()
    probe_stream(args.url, args.probesize, args.analyzeduration)