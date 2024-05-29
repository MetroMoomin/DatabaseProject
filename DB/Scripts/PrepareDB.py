import csv
import re

def parse_categories(input_file):
    categories = {}
    relationships = []

    with open(input_file, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            parent, sub = row[0], row[1]

            parent = re.sub(r'[^a-zA-Z0-9_]', '', parent)
            sub = re.sub(r'[^a-zA-Z0-9_]', '', sub)

            if sub not in categories:
                categories[sub] = len(categories)

            if parent not in categories:
                categories[parent] = len(categories)

            relationships.append((categories[parent], categories[sub]))

    return categories, relationships

def write_categories(categories, output_file):
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([':ID', 'Category'])
        for category, idx in categories.items():
            writer.writerow([idx, category])

def write_relationships(relationships, output_file):
    with open(output_file, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([':START_ID', ':END_ID'])
        for relationship in relationships:
            writer.writerow(relationship)

def main(input_file, categories_output_file, relationships_output_file):
    categories, relationships = parse_categories(input_file)
    write_categories(categories, categories_output_file)
    write_relationships(relationships, relationships_output_file)

if __name__ == "__main__":
    main("db.csv", "categories.csv", "relationships.csv")
