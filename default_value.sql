--*************************************************************************
--Gestion des valeurs par défaut issues de selection
--*************************************************************************
	--Fonction récupérant l'identifiant de la session courante
Create Or Replace Function func_default() 
	Returns integer AS 
$BODY$
	DECLARE 
		sesID public.session.id%TYPE; --Identifiant de la session à prendre en défaut pour la clé référençant
	BEGIN
		sesID = (Select id 
					From public.session
					Join public.etat_session ON etses_id = ses_etat
					Where etat in ('en cours', 'créée') LIMIT 1);
		RETURN sesID;
	END;
$BODY$
	LANGUAGE 'plpgsql';
					
	-- Affectation de la fonction en valeur par defaut sur observation_bordure et observation_surface
ALTER TABLE public.observation_surface ALTER COLUMN id_session SET DEFAULT (func_curr_session());
ALTER TABLE public.observation_bordure ALTER COLUMN id_session SET DEFAULT (func_curr_session());