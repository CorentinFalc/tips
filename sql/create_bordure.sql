--*************************************************************************
--Fonction de création de bordure à partir de lisiere et de parcelle
--*************************************************************************

CREATE OR REPLACE FUNCTION public.func_create_bordure()
  RETURNS integer AS
$BODY$
	DECLARE
		b public.temp_bordure%rowtype;--Variable récupérant les données de la table bordure
		b2 public.temp_bordure%rowtype; -- Variable récupérant les données de la table bordure à comparer 
		count integer;--Variable récupérant le nombre de données à parcourir
		bL1 public.lisiere.lis_id%TYPE;--Variable récupérent l'identifiant d'une lisiere
		bL2 public.lisiere.lis_id%TYPE;--Variable récupérant l'identifiant de la deuxième lisière
		bufferFin integer;--Taille du buffer servant pour la bordure
		bufferDebut integer;-- Taille du buffer de base
		lTemp public.lisiere.lis_id%Type;-- Lisière sur laquelle sera réalisé la bordure
		nb integer;-- Nombre de données parcourues
		d1 double precision;-- distance entre l1 et l2
		d2 double precision;-- Distance entre le centroid L1 et l2
		d3 double precision;-- Distance entre le centroid l2 et l1
		d4 double precision;-- Distance entre le centroid l1 et centroid l2
	BEGIN
		bufferDebut = 5;
		nb = 0;
		For lTemp in  Select lis_id From public.lisiere LOOP
			For bL1, bL2, d1, d2, d3, d4 in Select l1.lis_id, l2.lis_id, st_distance((l1.geom), (l2.geom)) as dist, st_distance(st_centroid(l1.geom), (l2.geom)), st_distance(st_centroid(l2.geom), (l1.geom)), st_distance(st_centroid(l2.geom), st_centroid(l1.geom))
											From lisiere l1, lisiere l2, surface s
											Where l1.lis_id != l2.lis_id
											AND st_length(st_intersection(l1.geom, s.geom)) > 5
											AND st_length(st_intersection(l2.geom, s.geom)) > 5
											AND (st_distance(l1.geom, l2.geom) > 0 OR (st_distance (st_centroid(l1.geom), l2.geom) <5 OR st_distance(st_centroid(l2.geom), l1.geom) <5))
											AND st_distance(l1.geom, l2.geom) <5
											ORDER by l1.lis_code, l2.lis_code, surf_code 
			LOOP
				IF lTemp = bL1 THEN
					IF d1 > 0 THEN
						IF (d2 < 20 OR d3 < 20 )THEN
							bufferFin = d1/2;
						END IF;
					ELSE
						IF d2 < d3 AND d2 < d4 THEN
							bufferFin = d2/2;
						ELSIF d3 < d2 AND d3 < d4 THEN
							bufferFin = d3/2;
						ELSE
							bufferFin = d4/2;
						END IF;
					END IF;
					EXIT;
				ELSE 
					bufferFin = bufferDebut;
				END IF;
			END LOOP;
			--RAISE NOTICE 'lis : %, buff : %, d1 : %, d2 : %, d3 : %, d4 : %', lTemp, bufferFin, d1, d2, d3, d4;
			INSERT INTO temp_bordure (tb_geom, tb_surface, tb_lisiere, tb_code_lis, tb_code_surf, tb_code_concat, tb_buffer)
			Select st_intersection(st_buffer(l.geom, bufferFin, 'endcap=flat'), s.geom), s.surf_id, l.lis_id, l.lis_code, s.surf_code, l.lis_code || s.surf_code, bufferFin
			From surface s, lisiere l
			Where st_dwithin(l.geom, s.geom, 2)
			AND l.lis_id = lTemp;
			
			nb = nb+1;

		END LOOP;
		
		RETURN nb;
	END;
$BODY$
	LANGUAGE 'plpgsql';

delete from temp_bordure;

select func_temp_bordure();













