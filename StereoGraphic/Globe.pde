float[][] load_map_data() {
  float map_data[][] = null;
  float rows_data[] = null;
  Table table;
  int setIndex = 0;
  int recordIndex = 0;
  table = loadTable("coasts.csv");
  for (TableRow row : table.rows ()) {
    if (row.getString(1).equals("sets")) {
      int sets = row.getInt(0);
      map_data = new float[sets][];
    } else if (row.getString(1).equals("records")) {
      int records = row.getInt(0)  * 2;
      map_data[setIndex] = new float[records];
      recordIndex = 0;
      rows_data = map_data[setIndex];
      setIndex++;
    } else {
      rows_data[recordIndex] = row.getFloat(0);
      recordIndex++;
      rows_data[recordIndex] = row.getFloat(1);
      recordIndex++;
    }
  }
  return map_data;
}

