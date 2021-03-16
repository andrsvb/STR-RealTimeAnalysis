
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;
with Sintomas;
with Medidas;


-- Packages needed to generate pulse interrupts       
-- with Ada.Interrupts.Names;
-- with Pulse_Interrupt; use Pulse_Interrupt;

package body add is

    ----------------------------------------------------------------------
    ------------- periodos y prioridades de las tareas  
    ----------------------------------------------------------------------
    pri_cabeza : Priority := Priority(5);
    pri_volante : Priority := Priority(2);
    pri_distancia : Priority := Priority(3);
    pri_riesgos : Priority := Priority(4);
    pri_display : Priority := Priority(1);
    							-- periodo original (deadline original)
    per_cabeza : Time_Span := Milliseconds(700);	-- 400 (100)
    per_volante : Time_Span := Milliseconds(650);	-- 350
    per_distancia : Time_Span := Milliseconds(600);	-- 300
    per_riesgos : Time_Span := Milliseconds(300);	-- 150
    per_display : Time_Span := Milliseconds(1500);	-- 1000
    
    
    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    
    
    ----------------------------------------------------------------------
    ----------- Tarea para probar Time_per_Kwhetstones
    ----------------------------------------------------------------------
    
	task task_prueba is
		pragma priority(100);
	end task_prueba;
	
	
    ----------------------------------------------------------------------	
    -------- Aqui se declaran las tareas que forman el STR
    ----------------------------------------------------------------------
    	
	task task_cabeza is
		pragma priority(pri_cabeza);
	end task_cabeza;

	task task_volante is
		pragma priority(pri_volante);
	end task_volante;

	task task_distancia is
		pragma priority(pri_distancia);
	end task_distancia;

	task task_riesgos is
		pragma priority(pri_riesgos);
	end task_riesgos;

	task task_display is
		pragma priority(pri_display);
	end task_display;


    -- Aqui se escriben los cuerpos de las tareas 
    
        
	task body task_prueba is
		inicio : Time;
    		fin : Time;
	begin
		Starting_Notice("PRUEBA TIEMPO");
		inicio := Clock;
		Execution_Time (Milliseconds(100));
		fin := Clock;
		Finishing_Notice("PRUEBA TIEMPO: " & Duration'Image(To_Duration(fin - inicio)));
	end task_prueba;

	task body task_cabeza is
		inicio : Time;
    		fin : Time;
    		inicioOP : Time;
    		finOP : Time;
		siguiente : Time;
		cabeza_actual : HeadPosition_Samples_Type;
		volante_actual : Steering_Samples_Type;
		inclina_x : Integer;
		inclina_y : Integer;
		x_peligroso : Integer := 0;
		y_peligroso : Integer := 0;
	begin
		siguiente := Clock + per_cabeza;
		loop
			Starting_Notice("CABEZA");
			inicio := Clock;

			Reading_HeadPosition(cabeza_actual);
			Reading_Steering(volante_actual);

			inclina_x := Integer(cabeza_actual(x));
			inclina_y := Integer(cabeza_actual(y));

			if ((inclina_x >= 30) OR (inclina_x <= -30)) then
				x_peligroso := x_peligroso + 1;
			else
				x_peligroso := 0;
			end if;

			if (((inclina_y >= 30) AND (volante_actual <= 0)) OR
				((inclina_y <= -30) AND (volante_actual >= 0))) then
				y_peligroso := y_peligroso + 1;
			else
				y_peligroso := 0;
			end if;

			inicioOP := Clock;
			sintomas.sintomasOP.eInclinacion((x_peligroso = 2) OR (y_peligroso = 2));
			finOP := Clock;
			
			fin := Clock;
			Finishing_Notice("CABEZA " & Duration'Image(To_Duration(fin - inicio)) & " ("
					  & Duration'Image(To_Duration(finOP - inicioOP)) & ")");
			delay until siguiente;
			siguiente := siguiente + per_cabeza;
		end loop;
	end task_cabeza;


	task body task_volante is
		inicio : Time;
    		fin : Time;
    		inicioOP : Time;
    		finOP : Time;
		siguiente : Time;
		volante_ant : Steering_Samples_Type := 0;
		volante_act : Steering_Samples_Type := 0;
		velocidad : Speed_Samples_type := 0;
	begin
		siguiente := Clock + per_volante;
		loop
			Starting_Notice("VOLANTE");
			inicio := Clock;
			Reading_Steering(volante_act);
			Reading_Speed(velocidad);

			inicioOP := Clock;
			sintomas.sintomasOP.eVolantazo((abs(volante_ant - volante_act) >= 20) AND (velocidad >= 40));
			finOP := Clock;
			
			volante_ant := volante_act;
			fin := Clock;

			Finishing_Notice("VOLANTE " & Duration'Image(To_Duration(fin - inicio)) & " ("
					  & Duration'Image(To_Duration(finOP - inicioOP)) & ")");

			delay until siguiente;
			siguiente := siguiente + per_volante;
		end loop;
	end task_volante;


	task body task_distancia is
		inicio : Time;
    		fin : Time;
    		inicioOP1 : Time;
    		finOP1 : Time;
    		inicioOP2 : Time;
    		finOP2 : Time;
		siguiente : Time;
		dist : Distance_Samples_Type := 0;
		speed : Speed_Samples_Type := 0;
		colision : Float;
		imprud : Float;
		inseg : Float;
		sIns : Boolean;
		sImp : Boolean;
		sCol : Boolean;
	begin
		siguiente := Clock + per_distancia;
		loop
			Starting_Notice("DISTANCIA ");
			inicio := Clock;
			
			Reading_Distance(dist);
			Reading_Speed(speed);

			inicioOP2 := Clock;
			medidas.medidasOP.eMedidas(dist, speed);
			finOP2 := Clock;

			colision := (((Float(speed)/10.0)**2)/3.0);
			imprud := (((Float(speed)/10.0)**2)/2.0);
			inseg := (((Float(speed)/10.0)**2));

			sIns := FALSE;
			sImp := FALSE;
			sCol := FALSE;
			if (dist < Distance_Samples_Type(colision)) then
				sCol := TRUE;
			elsif (dist < Distance_Samples_Type(imprud)) then
				sImp := TRUE;
			elsif (dist < Distance_Samples_Type(inseg)) then
				sIns := TRUE;
			end if;
			
			inicioOP1 := Clock;
			sintomas.sintomasOP.eDistancia(sIns, sImp, sCol);
			finOP1 := Clock;

			fin := Clock;
			Finishing_Notice("DISTANCIA " & Duration'Image(To_Duration(fin - inicio)) & " (sintomas: "
					  & Duration'Image(To_Duration(finOP1 - inicioOP1)) &", medidas: "
					  & Duration'Image(To_Duration(finOP2 - inicioOP2)) & ")");
			delay until siguiente;
			siguiente := siguiente + per_distancia;
		end loop;
	end task_distancia;

	task body task_riesgos is
		inicio : Time;
    		fin : Time;
    		inicioOP1 : Time;
    		finOP1 : Time;
    		inicioOP2 : Time;
    		finOP2 : Time;
		siguiente : Time;
		volantazo : Boolean;
		inclinacion : Boolean;
		distIns : Boolean;
		distImp : Boolean;
		riesgoC : Boolean;
		velocidad : Speed_Samples_Type;
		distancia : Distance_Samples_Type;
	begin
		siguiente := Clock + per_riesgos;
		loop
			Starting_Notice("RIESGOS");
			inicio := Clock;
			
			inicioOP1 := Clock;
			sintomas.sintomasOP.leeSintomas(volantazo, inclinacion, distIns, distImp,
								 riesgoC);
			finOP1 := Clock;
			inicioOP2 := Clock;
			medidas.medidasOP.leerMedidas(distancia, velocidad);
			finOP2 := Clock;

			if ((riesgoC = TRUE) AND (inclinacion = TRUE)) then
				Activate_Brake;
				Beep(5);
			else
				if (distImp = TRUE) then
					Beep(4);
				elsif (inclinacion = TRUE) then
					if (velocidad >= 70) then
						Beep(3);
					else
						Beep(2);
					end if;
				end if;
				
				if ((distIns = TRUE) OR (distImp = TRUE)) then
					Light(On);
				else
					Light(Off);
					if ((riesgoC = FALSE) AND (inclinacion = FALSE) AND (volantazo = TRUE)) then
						Beep(1);
					end if;
				end if;
			end if;			

			fin := Clock;
			Finishing_Notice("RIESGOS " & Duration'Image(To_Duration(fin - inicio)) & " (sintomas: "
					  & Duration'Image(To_Duration(finOP1 - inicioOP1)) &", medidas: "
					  & Duration'Image(To_Duration(finOP2 - inicioOP2)) & ")");
			delay until siguiente;
			siguiente := siguiente + per_riesgos;
		end loop;
	end task_riesgos;


	task body task_display is
		inicio : Time;
    		fin : Time;
    		inicioOP1 : Time;
    		finOP1 : Time;
    		inicioOP2 : Time;
    		finOP2 : Time;
		siguiente : Time;
		volantazo : Boolean;
		inclinacion : Boolean;
		distIns : Boolean;
		distImp : Boolean;
		riesgoC : Boolean;
		velocidad : Speed_Samples_Type;
		distancia : Distance_Samples_Type;
	begin
		siguiente := Clock + per_display;
		loop
			Starting_Notice("DISPLAY");
			inicio := Clock;
			
			inicioOP1 := Clock;
			sintomas.sintomasOP.leeSintomas(volantazo, inclinacion, distIns, distImp, riesgoC);
			finOP1 := Clock;
			
			inicioOP2 := Clock;
			medidas.medidasOP.leerMedidas(distancia, velocidad);
			finOP2 := Clock;

			Display_Speed(velocidad);
			Display_Distance(distancia);

			if ((volantazo = TRUE) AND (velocidad >= 40)) then
				Put_Line(" VOLANTAZO ");
			elsif (inclinacion = TRUE) then
				Put_Line(" INCLINACION ");
			elsif (distIns = TRUE) then
				Put_Line(" DISTANCIA INSEGURA ");
			elsif (distImp = TRUE) then
				Put_Line(" DISTANCIA IMPRUDENTE ");
			elsif (riesgoC = TRUE) then
				Put_Line(" RIESGO COLISION ");
			end if;


			fin := Clock;
			Finishing_Notice("DISPLAY " & Duration'Image(To_Duration(fin - inicio)) & " (sintomas: "
					  & Duration'Image(To_Duration(finOP1 - inicioOP1)) &", medidas: "
					  & Duration'Image(To_Duration(finOP2 - inicioOP2)) & ")");
			delay until siguiente;
			siguiente := siguiente + per_display;
		end loop;
	end task_display;



    ----------------------------------------------------------------------
    ------------- procedure para probar los dispositivos 
    ----------------------------------------------------------------------
    procedure Prueba_Dispositivos; 

    Procedure Prueba_Dispositivos is
        Current_V: Speed_Samples_Type := 0;
        Current_H: HeadPosition_Samples_Type := (+2,-2);
        Current_D: Distance_Samples_Type := 0;
        Current_O: Eyes_Samples_Type := (70,70);
        Current_E: EEG_Samples_Type := (1,1,1,1,1,1,1,1,1,1);
        Current_S: Steering_Samples_Type := 0;
    begin
         Starting_Notice ("Prueba_Dispositivo");

         for I in 1..120 loop
         -- Prueba distancia
            --Reading_Distance (Current_D);
            --Display_Distance (Current_D);
            --if (Current_D < 40) then Light (On); 
            --                    else Light (Off); end if;

         -- Prueba velocidad
            --Reading_Speed (Current_V);
            --Display_Speed (Current_V);
            --if (Current_V > 110) then Beep (2); end if;

         -- Prueba volante
         --   Reading_Steering (Current_S);
         --   Display_Steering (Current_S);
         --   if (Current_S > 30) OR (Current_S < -30) then Light (On);
         --                                            else Light (Off); end if;

         -- Prueba Posicion de la cabeza
            --Reading_HeadPosition (Current_H);
            --Display_HeadPosition_Sample (Current_H);
            --if (Current_H(x) > 30) then Beep (4); end if;

         -- Prueba ojos
            --Reading_EyesImage (Current_O);
            --Display_Eyes_Sample (Current_O);

         -- Prueba electroencefalograma
            --Reading_Sensors (Current_E);
            --Display_Electrodes_Sample (Current_E);
   
         delay until (Clock + To_time_Span(0.1));
         end loop;

         Finishing_Notice ("Prueba_Dispositivo");
    end Prueba_Dispositivos;


begin
   Starting_Notice ("Programa Principal");
   -- Prueba_Dispositivos;
   Finishing_Notice ("Programa Principal");
end add;
