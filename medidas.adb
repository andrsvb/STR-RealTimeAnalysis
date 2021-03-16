with devices; use devices;
with Tools; use Tools;
with Ada.Real_Time; use Ada.Real_Time;

package body medidas is
	protected body medidasOP is
		procedure eMedidas(D: in Distance_Samples_Type;
		                              V: in Speed_Samples_Type) is
		begin
			Execution_Time (Milliseconds(7));
			distanciaMedida := D;
			velocidadMedida := V;
		end eMedidas;


		procedure leerMedidas(D: out Distance_Samples_Type;
				      V: out Speed_Samples_Type) is
		begin
			Execution_Time (Milliseconds(2));
			D := distanciaMedida;
			V := velocidadMedida;
		end leerMedidas;

		end medidasOP;
end medidas;
