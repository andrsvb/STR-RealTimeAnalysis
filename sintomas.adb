with Tools; use Tools;
with Ada.Real_Time; use Ada.Real_Time;

package body sintomas is
	protected body sintomasOP is
		procedure eVolantazo(V: in Boolean) is 
		begin
			Execution_Time (Milliseconds(5));
			volantazo := V;
		end eVolantazo;

		procedure eInclinacion(I: in Boolean) is 
		begin
			Execution_Time (Milliseconds(5));
			inclinacion := I;
		end eInclinacion;

		procedure eDistancia(ins: in Boolean; imp: in Boolean; risk: in Boolean) is 
		begin
			Execution_Time (Milliseconds(8));
			distIns := ins;
			distImp := imp;
			riesgoC := risk;
		end eDistancia;
		

		procedure leeSintomas(V: out Boolean; I: out Boolean;
				    ins: out Boolean; imp: out Boolean;
				   risk: out Boolean) is
		begin
			Execution_Time (Milliseconds(3));
			V := volantazo;
			I := inclinacion;
			ins := distIns;
			imp := distImp;
			risk := riesgoC;
		end leeSintomas;

	end sintomasOP;
end sintomas;
