-- Name: Nghia Nguyen
-- Student number: 000275466

CREATE TABLE AnimalSpecies (
    AID         INTEGER,
    Name        VARCHAR(64),
    Nutrition   CHAR(1),
    Temperature FLOAT,
    Habitat     VARCHAR(64),
    minFlock    INTEGER,
    maxFlock    INTEGER,
    spaceRequirements   FLOAT        );
ALTER TABLE AnimalSpecies ADD CONSTRAINT PK_AnimalSpecies
    PRIMARY KEY(AID);
CREATE TABLE Habitat (
    HID         INTEGER,
    Name        VARCHAR(64),
    Habitat     VARCHAR(64),
    Size        FLOAT,
    Temperature FLOAT           );
ALTER TABLE Habitat ADD CONSTRAINT PK_Habitat
    PRIMARY KEY(HID);
CREATE TABLE Specimen (
    EID       INTEGER,
    AID       INTEGER,
    HID       INTEGER,
    Name      VARCHAR(64),
    BirthDate   DATE,
    Gender    CHAR(1),
    Weight    FLOAT,
    Height    FLOAT            );
ALTER TABLE Specimen ADD CONSTRAINT PK_Specimen
    PRIMARY KEY(EID);
ALTER TABLE Specimen ADD CONSTRAINT FK_Specimen1
    FOREIGN KEY(AID) REFERENCES AnimalSpecies(AID);
ALTER TABLE Specimen ADD CONSTRAINT FK_Specimen2
    FOREIGN KEY(HID) REFERENCES Habitat(HID);
CREATE TABLE Ancestry (
    EID     INTEGER,
    Parent  INTEGER      );
ALTER TABLE Ancestry ADD CONSTRAINT PK_Ancestry
    PRIMARY KEY(EID, Parent);
ALTER TABLE ancestry ADD CONSTRAINT FK_Ancestry1
    FOREIGN KEY(EID) REFERENCES Specimen(EID);
ALTER TABLE Ancestry ADD CONSTRAINT FK_Ancestry2
    FOREIGN KEY(Parent) REFERENCES Specimen(EID);

-- a) Parents are not younger than their offsprings
CREATE OR REPLACE FUNCTION check_parent_birthdate()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
	AS
	$$
	BEGIN
		IF (SELECT BirthDate AS EID_birth 
			FROM Specimen 
			WHERE EID = NEW.EID) < 
		(SELECT BirthDate AS parent_birth 
		 FROM Specimen 
		 WHERE EID = NEW.Parent)
		THEN RAISE EXCEPTION 'Parents are not younger than their offsprings';
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;

CREATE OR REPLACE TRIGGER check_new_ancestry_input
	BEFORE INSERT OR UPDATE ON ancestry
	FOR EACH ROW
	EXECUTE FUNCTION check_parent_birthdate();
	
--b) Temperature should not differ more than 5 degrees of what the species needs.
CREATE OR REPLACE FUNCTION check_habitat()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
	AS
	$$
	BEGIN
		IF (NEW.Temperature > (SELECT habitat.Temperature AS habitat_temp 
							   FROM habitat 
							   WHERE NEW.Habitat = habitat.Name) + 5)
		OR (NEW.Temperature < (SELECT habitat.Temperature AS habitat_temp 
							   FROM habitat 
							   WHERE NEW.Habitat = habitat.Name) - 5)
		THEN RAISE EXCEPTION 'Temperature should not differ more than 5 degrees of what the species needs.';
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;
	
CREATE OR REPLACE TRIGGER check_new_species_habitat
	BEFORE INSERT OR UPDATE ON animalspecies
	FOR EACH ROW
	EXECUTE FUNCTION check_habitat();
	
--c) Compare Habitat size to specimen weight or height or use size as "number of animals possible."
CREATE OR REPLACE FUNCTION compare_habitat_size()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
	AS
	$$
	BEGIN
		IF (SELECT Habitat.size FROM Habitat WHERE Habitat.HID = NEW.HID) -
		(SELECT SUM(AnimalSpecies.spaceRequirements) FROM Specimen INNER JOIN AnimalSpecies ON Specimen.AID = AnimalSpecies.AID WHERE Specimen.HID = New.HID) <
		(SELECT AnimalSpecies.spaceRequirements FROM AnimalSpecies WHERE AnimalSpecies.AID = NEW.AID)
		THEN RAISE EXCEPTION 'Habitat overbooked!';
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;

CREATE OR REPLACE TRIGGER check_new_specimen_habit_size
	BEFORE INSERT OR UPDATE ON Specimen
	FOR EACH ROW
	EXECUTE FUNCTION compare_habitat_size();
	
-- d) Offsprings have at MOST one male, one female parent.
CREATE OR REPLACE FUNCTION check_insert_ancestry_parent_sex()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
	AS
	$$
	BEGIN
		IF ((SELECT COUNT(*) 
			 FROM Ancestry 
			 WHERE EID = NEW.EID) = 2)
		THEN RAISE EXCEPTION 'Offsprings have at MOST one male, one female parent.';
		ELSEIF((SELECT Gender 
				FROM Specimen 
				WHERE EID = NEW.parent) IS NOT NULL)
		THEN 
			IF ((SELECT Gender 
				 FROM Specimen 
				 WHERE EID = NEW.parent) = (SELECT Gender FROM Specimen WHERE EID = (SELECT parent FROM Ancestry WHERE EID = NEW.EID)))
			THEN RAISE EXCEPTION 'Offsprings have at MOST one male, one female parent.';
			ELSE
			RETURN NEW;
			END IF;
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;

CREATE OR REPLACE FUNCTION check_update_ancestry_parent_sex()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
	$$
	BEGIN
		IF((SELECT Gender 
			FROM Specimen 
			WHERE EID = NEW.parent) IS NOT NULL)
		THEN 
			IF ((SELECT Gender 
				 FROM Specimen 
				 WHERE EID = NEW.parent) = (SELECT Gender FROM Specimen WHERE EID = (SELECT parent FROM Ancestry WHERE EID = NEW.EID)))
			THEN RAISE EXCEPTION 'Offsprings have at MOST one male, one female parent. NULL ALLOWED';
			ELSE
			RETURN NEW;
			END IF;
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;
	
CREATE OR REPLACE FUNCTION check_update_specimen_parent_sex()
	RETURNS TRIGGER
	LANGUAGE 'plpgsql'
	AS
	$$
	BEGIN
		IF (NEW.Gender IS NOT NULL)
		THEN
			IF ((SELECT Gender 
				 FROM Specimen 
				 WHERE EID = (SELECT parent FROM Ancestry WHERE (parent !=NEW.EID) AND (EID = (SELECT EID FROM Ancestry WHERE parent = NEW.EID)))) = NEW.Gender)
			THEN RAISE EXCEPTION 'Offsprings have at MOST one male, one female parent. NULL ALLOWED';
			ELSE
			RETURN NEW;
			END IF;
		ELSE
		RETURN NEW;
		END IF;
	END;
	$$;
	
CREATE OR REPLACE TRIGGER check_insert_ancestry_parent
	BEFORE INSERT ON ancestry
	FOR EACH ROW
	EXECUTE FUNCTION check_insert_ancestry_parent_sex();

CREATE OR REPLACE TRIGGER check_update_ancestry_parent
	BEFORE UPDATE ON ancestry
	FOR EACH ROW
	EXECUTE FUNCTION check_update_ancestry_parent_sex();
	
CREATE OR REPLACE TRIGGER check_update_specimen_parent
	BEFORE UPDATE ON specimen
	FOR EACH ROW
	EXECUTE FUNCTION check_update_specimen_parent_sex();