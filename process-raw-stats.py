import pandas


def get_stat(row):
    return row["data"].split(":")[0] \
      .replace("{", "").replace("}", "").replace("'", "") \
      .strip()


def get_value(row):
    clean_value = row["data"].split(":")[1] \
        .replace("{", "").replace("}", "").replace("'", "").replace(",", "") \
        .strip()
    try:
        return float(clean_value)
    except:
        return clean_value


def produce_df(input_sheet_df_raw):
    input_sheet_df = input_sheet_df_raw.copy()
    input_sheet_df["stat"] = input_sheet_df.apply(get_stat, axis=1)
    input_sheet_df["value"] = input_sheet_df.apply(get_value, axis=1)
    del input_sheet_df["data"]

    groups = list(input_sheet_df.groupby(by="year"))
    yearly_records = list(map(groupify, groups))
    return pandas.DataFrame(yearly_records)

def extract_value(stat, values):
    return values.loc[values['stat'] == stat]["value"].tolist()[0]

def groupify(group):
    year, values = group
    ret = {
        "year": year,
        "mean": extract_value("MEAN", values),
        "min": extract_value("MIN", values),
        "max": extract_value("MAX", values),
        "std_dev": extract_value("STD_DEV", values),
        "sum": extract_value("SUM", values),
        "sum_of_squares": extract_value("SUM_OF_SQUARES", values),
    }
    return ret



in_path = "./raw-raster-layer-pastes.xlsx"
out_path = "./raster-layer-statistics-{}.xlsx"
biblical = produce_df(pandas.read_excel(in_path, sheet_name="Biblical"))
modern = produce_df(pandas.read_excel(in_path, sheet_name="Modern"))

biblical.to_excel(out_path.format("biblical"))
modern.to_excel(out_path.format("modern"))

# def summarize(df):
#     global_mean = df["mean"].mean()
#     deviations = (df["mean"] - global_mean) / df["std_dev"]
#     print(deviations)

# summarize(biblical)
