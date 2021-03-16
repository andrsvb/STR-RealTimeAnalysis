
package sintomas is
	protected sintomasOP is
		pragma priority(5);
		procedure eVolantazo(V: in Boolean);
		procedure eInclinacion(I: in Boolean);
		procedure eDistancia(ins: in Boolean; imp: in Boolean; risk: in Boolean);

		procedure leeSintomas(V: out Boolean; I: out Boolean; ins: out Boolean;
					   	    imp: out Boolean; risk: out Boolean);

	private
		volantazo: Boolean;
		inclinacion: Boolean;
		distIns: Boolean;
		distImp: Boolean;
		riesgoC: Boolean;
	end sintomasOP;

end sintomas;






