with devices; use devices;

package medidas is
	protected medidasOP is
		pragma priority(4);
		procedure eMedidas(D: in Distance_Samples_Type;
		                   V: in Speed_Samples_Type);
		
		procedure leerMedidas(D: out Distance_Samples_Type;
				      V: out Speed_Samples_Type);
		
	private
		distanciaMedida: Distance_Samples_type;
		velocidadMedida: Speed_Samples_Type;
	end medidasOP;
end medidas;
