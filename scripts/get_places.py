import json
import urllib
from dataclasses import dataclass
from multiprocessing import Pool
from pathlib import Path

import requests
from parsel import Selector

TEI_NAMESPACE = "http://www.tei-c.org/ns/1.0"

input_file = Path(__file__).parent / "../data/Abt-1_Tiefbau_Band-1.xml"

with open(input_file) as f:
    xml = f.read()

xml_selector = Selector(xml, type="xml")

places_from_index = xml_selector.xpath(
    "//tei:place[parent::tei:listPlace]", namespaces={"tei": TEI_NAMESPACE}
)


@dataclass
class Place:
    name: str
    place_id: str
    lat: str
    long: str
    found_at_retry: bool


GEO_NS = "http://www.w3.org/2003/01/geo/wgs84_pos#"


def get_name_and_id(place: Selector) -> tuple[str, str]:
    place_name = place.xpath("normalize-space(string())").get()

    place_id = place.xpath("@xml:id").get()
    assert place_id is not None

    return place_name, place_id


def fetch_place_data(
    place_infos: tuple[str, str], split_place: bool = False, retry: bool = True
) -> Place | None:
    place_name = place_infos[0]
    place_id = place_infos[1]

    if split_place:
        place_name = place_name.split(" ")[0]

    print(f"Fetching data for {place_name}")

    params = {"q": place_name, "details": "true"}

    try:
        url = f"https://ref.de.dariah.eu/tgn/v1/exact-match.json?{urllib.parse.urlencode(params)}"
        try:
            result = requests.get(url)
        except Exception as _:
            print("Dariah API abgeschmiert für ", url)
            return None
        result = result.json()

        term = result.get("term")
        if term is not None:
            hit = term[0] if isinstance(term, list) else term
            rdf_link = hit.get("rdf-link")

            getty_result = requests.get(rdf_link.get("target"))

            parsed_result = Selector(getty_result.text, type="xml")

            lat = parsed_result.xpath(
                "//geo:lat/text()", namespaces={"geo": GEO_NS}
            ).get()
            long = parsed_result.xpath(
                "//geo:long/text()", namespaces={"geo": GEO_NS}
            ).get()

            if lat is None or long is None:
                print(f"Could not find lat/long for {place_name}")
                return None

            print(f"Found lat/long for {place_name} with id {place_id} at {lat}/{long}")

            return Place(
                name=place_name,
                place_id=place_id,
                lat=lat,
                long=long,
                found_at_retry=retry,
            )
        else:
            print(f"No result found for {place_name}")

            if retry:
                print("Trying again with split place name")
                return fetch_place_data(place_infos, split_place=True, retry=False)

            return None
    except Exception as _:
        print(f"Error could not fetch data for {place_name}...")
        return None


if __name__ == "__main__":
    print(f"Starting to fetch data for {len(places_from_index)} places")

    with Pool(4) as p:
        places_hits = p.map(
            fetch_place_data, [get_name_and_id(p) for p in places_from_index]
        )

    places_hits = [place for place in places_hits if place is not None]
    print(f"Found {len(places_hits)} hits out of {len(places_from_index)}")
    output_file = Path(__file__).parent / "../data/places.json"
    print(f"Writing results to {output_file}")

    with open(output_file, "w") as f:
        json.dump([place.__dict__ for place in places_hits], f)
