function csvLineToJson(csvLine) {
    const values = csvLine.split(';');
  
    const jsonObject = {
      dateHour: values[0],
      gpsSpeed: values[1],
      gpsSatCount: values[2],
      Gear: values[3],
      Brake_pedal: values[4],
      Accel_pedal: values[5],
      Machine_Speed_Mesured: values[6],
      AST_Direction: values[7],
      Ast_HPMB1_Pressure_bar: values[8],
      Ast_HPMA_Pressure_bar: values[9],
      Pressure_HighPressureReturn: values[10],
      Pressure_HighPressure: values[11],
      Oil_Temperature: values[12],
      Ast_FrontAxleSpeed_Rpm: values[13],
      Pump_Speed: values[14],
      clienID: values[15]
    };
  
    return jsonObject;
  }
  