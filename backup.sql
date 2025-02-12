PGDMP                      }            bd    16.2    16.2 4    "           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            #           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            $           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            %           1262    16461    bd    DATABASE     v   CREATE DATABASE bd WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE bd;
                postgres    false            �            1255    24669 !   delete_records_except(text, text)    FUNCTION     �   CREATE FUNCTION public.delete_records_except(table_name text, condition text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE 'DELETE FROM ' || table_name || ' WHERE NOT (' || condition || ')';
END;
$$;
 M   DROP FUNCTION public.delete_records_except(table_name text, condition text);
       public          postgres    false            �            1255    24662    fill_table()    FUNCTION     G  CREATE FUNCTION public.fill_table() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INTEGER := 7000;
BEGIN
    WHILE i <= 17000 LOOP
        INSERT INTO filial (kod_filiala, name_filiala, adres, telefon) VALUES (i, 'value' || i, 'description' || i, LPAD(i::TEXT, 10, '0'));
        i := i + 1;
    END LOOP;
END;
$$;
 #   DROP FUNCTION public.fill_table();
       public          postgres    false            �            1255    24608    kol_dogovorov(integer)    FUNCTION     �   CREATE FUNCTION public.kol_dogovorov(vvod integer) RETURNS bigint
    LANGUAGE sql
    AS $$
select count(nomer_dogovora)  
from dogovor
WHERE kod_agenta = vvod
$$;
 2   DROP FUNCTION public.kol_dogovorov(vvod integer);
       public          postgres    false            �            1255    24605 Y   new_dogovor(integer, date, double precision, double precision, integer, integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.new_dogovor(IN nomer_dogovora integer, IN data_zakl date, IN strahovja_sum double precision, IN tarifnja_stavka double precision, IN kod_filiala integer, IN kod_vida_strahovania integer, IN kod_agenta integer)
    LANGUAGE sql
    AS $$
insert into dogovor values (nomer_dogovora, data_zakl, strahovja_sum, tarifnja_stavka, 
kod_filiala, kod_vida_strahovania, kod_agenta)
$$;
 �   DROP PROCEDURE public.new_dogovor(IN nomer_dogovora integer, IN data_zakl date, IN strahovja_sum double precision, IN tarifnja_stavka double precision, IN kod_filiala integer, IN kod_vida_strahovania integer, IN kod_agenta integer);
       public          postgres    false            �            1255    24654    poisk_po_fam(character) 	   PROCEDURE     �   CREATE PROCEDURE public.poisk_po_fam(IN vvod character)
    LANGUAGE plpgsql
    AS $$

BEGIN

    Select * FROM strahovoi_agent WHERE familia Like 'vvod%';
END;
$$;
 7   DROP PROCEDURE public.poisk_po_fam(IN vvod character);
       public          postgres    false            �            1255    24631    pr_2(integer) 	   PROCEDURE     �   CREATE PROCEDURE public.pr_2(IN vvod integer)
    LANGUAGE sql
    AS $$

select * from dogovor 
where dogovor.strahovja_sum < vvod;

$$;
 -   DROP PROCEDURE public.pr_2(IN vvod integer);
       public          postgres    false            �            1255    24629    trigger_del()    FUNCTION     g  CREATE FUNCTION public.trigger_del() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    contract_count INTEGER;
BEGIN
    -- Подсчитываем количество договоров в филиале
    SELECT COUNT(*)
    INTO contract_count
    FROM dogovor
    WHERE kod_filiala = OLD.kod_filiala;

    -- Проверяем, является ли удаляемый договор последним в филиале
    IF contract_count = 1 THEN
        RAISE EXCEPTION 'Нельзя удалить последний договор в филиале';
    END IF;

    RETURN OLD;
END;
$$;
 $   DROP FUNCTION public.trigger_del();
       public          postgres    false            �            1255    24623    trigger_ins()    FUNCTION     �   CREATE FUNCTION public.trigger_ins() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if new.procent is NULL
then new.procent = 7;
end if;
return new;
end;
$$;
 $   DROP FUNCTION public.trigger_ins();
       public          postgres    false            �            1255    24621    trigger_upd()    FUNCTION     �   CREATE FUNCTION public.trigger_upd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if(new.tarifnja_stavka > 30)
then raise exception 'невозможный процент тарифной ставки';
end if;
end;
$$;
 $   DROP FUNCTION public.trigger_upd();
       public          postgres    false            �            1255    24645    zp_ag(integer)    FUNCTION     �  CREATE FUNCTION public.zp_ag(nom_dog integer) RETURNS TABLE(kod_agenta integer, familia character varying, imja character varying, otchestvo character varying, nomer_dogovora integer, "ZP_ag" double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY 
   SELECT dg."kod_agenta", ag."familia", ag."imja", ag."otchestvo", dg."nomer_dogovora", (st."procent"*dg."strahovja_sum"*dg."tarifnja_stavka"/10000) as "ZP_ag"
  FROM "dogovor" dg
  INNER JOIN "strahovoi_agent" ag
    ON dg."kod_agenta" = ag."kod_agenta"
  INNER JOIN "vid_strahovania" st
    ON dg."kod_vida_strahovania" = st."kod_vida_strahovania"
  WHERE "nom_dog" = dg."nomer_dogovora";
END
$$;
 -   DROP FUNCTION public.zp_ag(nom_dog integer);
       public          postgres    false            �            1259    24600    activ_filial    VIEW     �   CREATE VIEW public.activ_filial AS
SELECT
    NULL::integer AS kod_filiala,
    NULL::character varying(20) AS name_filiala,
    NULL::bigint AS count;
    DROP VIEW public.activ_filial;
       public          postgres    false            &           0    0    TABLE activ_filial    ACL     ;   GRANT SELECT,INSERT ON TABLE public.activ_filial TO danil;
          public          postgres    false    220            �            1259    16478    dogovor    TABLE        CREATE TABLE public.dogovor (
    nomer_dogovora integer NOT NULL,
    data_zakl date NOT NULL,
    strahovja_sum double precision NOT NULL,
    tarifnja_stavka double precision NOT NULL,
    kod_filiala integer NOT NULL,
    kod_vida_strahovania integer NOT NULL,
    kod_agenta integer,
    CONSTRAINT dogovor_strahovja_sum_check CHECK ((strahovja_sum > (0)::double precision)),
    CONSTRAINT dogovor_tarifnja_stavka_check CHECK ((tarifnja_stavka > (0)::double precision))
)
WITH (autovacuum_enabled='true');
    DROP TABLE public.dogovor;
       public         heap    postgres    false            '           0    0    TABLE dogovor    ACL     6   GRANT SELECT,INSERT ON TABLE public.dogovor TO danil;
          public          postgres    false    218            �            1259    24580 
   ag_filipov    VIEW     �   CREATE VIEW public.ag_filipov AS
 SELECT nomer_dogovora,
    kod_filiala,
    kod_vida_strahovania,
    strahovja_sum,
    tarifnja_stavka,
    kod_agenta
   FROM public.dogovor
  WHERE (kod_agenta = 70)
  WITH CASCADED CHECK OPTION;
    DROP VIEW public.ag_filipov;
       public          postgres    false    218    218    218    218    218    218            (           0    0    TABLE ag_filipov    ACL     9   GRANT SELECT,INSERT ON TABLE public.ag_filipov TO danil;
          public          postgres    false    219            �            1259    16468    filial    TABLE     !  CREATE TABLE public.filial (
    kod_filiala integer NOT NULL,
    name_filiala character varying(20) NOT NULL,
    adres character varying(20) NOT NULL,
    telefon text NOT NULL,
    CONSTRAINT filial_telefon_check CHECK ((char_length(telefon) = 10))
)
WITH (autovacuum_enabled='true');
    DROP TABLE public.filial;
       public         heap    postgres    false            )           0    0    TABLE filial    ACL     5   GRANT SELECT,INSERT ON TABLE public.filial TO danil;
          public          postgres    false    216            �            1259    16462    strahovoi_agent    TABLE     �  CREATE TABLE public.strahovoi_agent (
    familia character varying(20) NOT NULL,
    imja character varying(20) NOT NULL,
    otchestvo character varying(20) NOT NULL,
    adres character varying(20) NOT NULL,
    telefon_agenta text NOT NULL,
    kod_filiala integer NOT NULL,
    kod_agenta integer NOT NULL,
    CONSTRAINT strahovoi_agent_telefon_agenta_check CHECK ((char_length(telefon_agenta) = 10))
)
WITH (autovacuum_enabled='true');
 #   DROP TABLE public.strahovoi_agent;
       public         heap    postgres    false            *           0    0    TABLE strahovoi_agent    ACL     >   GRANT SELECT,INSERT ON TABLE public.strahovoi_agent TO danil;
          public          postgres    false    215            �            1259    16473    vid_strahovania    TABLE        CREATE TABLE public.vid_strahovania (
    kod_vida_strahovania integer NOT NULL,
    name character varying(20) NOT NULL,
    procent integer NOT NULL,
    CONSTRAINT "Vid_stahovania_procent_check" CHECK ((procent > 0))
)
WITH (autovacuum_enabled='true');
 #   DROP TABLE public.vid_strahovania;
       public         heap    postgres    false            +           0    0    TABLE vid_strahovania    ACL     >   GRANT SELECT,INSERT ON TABLE public.vid_strahovania TO danil;
          public          postgres    false    217                      0    16478    dogovor 
   TABLE DATA           �   COPY public.dogovor (nomer_dogovora, data_zakl, strahovja_sum, tarifnja_stavka, kod_filiala, kod_vida_strahovania, kod_agenta) FROM stdin;
    public          postgres    false    218   G                 0    16468    filial 
   TABLE DATA           K   COPY public.filial (kod_filiala, name_filiala, adres, telefon) FROM stdin;
    public          postgres    false    216   �G                 0    16462    strahovoi_agent 
   TABLE DATA           s   COPY public.strahovoi_agent (familia, imja, otchestvo, adres, telefon_agenta, kod_filiala, kod_agenta) FROM stdin;
    public          postgres    false    215   yH                 0    16473    vid_strahovania 
   TABLE DATA           N   COPY public.vid_strahovania (kod_vida_strahovania, name, procent) FROM stdin;
    public          postgres    false    217   �I       ~           2606    16477 !   vid_strahovania PK_Vid_stahovania 
   CONSTRAINT     s   ALTER TABLE ONLY public.vid_strahovania
    ADD CONSTRAINT "PK_Vid_stahovania" PRIMARY KEY (kod_vida_strahovania);
 M   ALTER TABLE ONLY public.vid_strahovania DROP CONSTRAINT "PK_Vid_stahovania";
       public            postgres    false    217            �           2606    16485    dogovor PK_dogovor 
   CONSTRAINT     ^   ALTER TABLE ONLY public.dogovor
    ADD CONSTRAINT "PK_dogovor" PRIMARY KEY (nomer_dogovora);
 >   ALTER TABLE ONLY public.dogovor DROP CONSTRAINT "PK_dogovor";
       public            postgres    false    218            v           2606    16472    filial PK_filial 
   CONSTRAINT     Y   ALTER TABLE ONLY public.filial
    ADD CONSTRAINT "PK_filial" PRIMARY KEY (kod_filiala);
 <   ALTER TABLE ONLY public.filial DROP CONSTRAINT "PK_filial";
       public            postgres    false    216            t           2606    16467 "   strahovoi_agent PK_strahovoi_agent 
   CONSTRAINT     j   ALTER TABLE ONLY public.strahovoi_agent
    ADD CONSTRAINT "PK_strahovoi_agent" PRIMARY KEY (kod_agenta);
 N   ALTER TABLE ONLY public.strahovoi_agent DROP CONSTRAINT "PK_strahovoi_agent";
       public            postgres    false    215                       1259    16481    IX_Relationship3    INDEX     L   CREATE INDEX "IX_Relationship3" ON public.dogovor USING btree (kod_agenta);
 &   DROP INDEX public."IX_Relationship3";
       public            postgres    false    218            �           1259    16482    IX_Relationship6    INDEX     V   CREATE INDEX "IX_Relationship6" ON public.dogovor USING btree (kod_vida_strahovania);
 &   DROP INDEX public."IX_Relationship6";
       public            postgres    false    218            r           1259    16465    IX_Relationship7    INDEX     U   CREATE INDEX "IX_Relationship7" ON public.strahovoi_agent USING btree (kod_filiala);
 &   DROP INDEX public."IX_Relationship7";
       public            postgres    false    215            �           1259    16483    IX_Relationship9    INDEX     M   CREATE INDEX "IX_Relationship9" ON public.dogovor USING btree (kod_filiala);
 &   DROP INDEX public."IX_Relationship9";
       public            postgres    false    218            w           1259    24665    id1_kod_filiala    INDEX     I   CREATE INDEX id1_kod_filiala ON public.filial USING btree (kod_filiala);
 #   DROP INDEX public.id1_kod_filiala;
       public            postgres    false    216            x           1259    24664    id_kod_filiala    INDEX     H   CREATE INDEX id_kod_filiala ON public.filial USING btree (kod_filiala);
 "   DROP INDEX public.id_kod_filiala;
       public            postgres    false    216            y           1259    24667    idx1_kod_filiala    INDEX     J   CREATE INDEX idx1_kod_filiala ON public.filial USING btree (kod_filiala);
 $   DROP INDEX public.idx1_kod_filiala;
       public            postgres    false    216            z           1259    24666    idx_kod_filiala    INDEX     I   CREATE INDEX idx_kod_filiala ON public.filial USING btree (kod_filiala);
 #   DROP INDEX public.idx_kod_filiala;
       public            postgres    false    216            {           1259    24663    index_kod_filiala    INDEX     K   CREATE INDEX index_kod_filiala ON public.filial USING btree (kod_filiala);
 %   DROP INDEX public.index_kod_filiala;
       public            postgres    false    216            |           1259    24668    indx_kod_filiala    INDEX     J   CREATE INDEX indx_kod_filiala ON public.filial USING btree (kod_filiala);
 $   DROP INDEX public.indx_kod_filiala;
       public            postgres    false    216                       2618    24603    activ_filial _RETURN    RULE     
  CREATE OR REPLACE VIEW public.activ_filial AS
 SELECT filial.kod_filiala,
    filial.name_filiala,
    count(dogovor.nomer_dogovora) AS count
   FROM public.dogovor,
    public.filial
  WHERE (filial.kod_filiala = dogovor.kod_filiala)
  GROUP BY filial.kod_filiala;
 �   CREATE OR REPLACE VIEW public.activ_filial AS
SELECT
    NULL::integer AS kod_filiala,
    NULL::character varying(20) AS name_filiala,
    NULL::bigint AS count;
       public          postgres    false    216    218    4726    218    216    220            �           2620    24630    dogovor del_tr1    TRIGGER     k   CREATE TRIGGER del_tr1 BEFORE DELETE ON public.dogovor FOR EACH ROW EXECUTE FUNCTION public.trigger_del();
 (   DROP TRIGGER del_tr1 ON public.dogovor;
       public          postgres    false    218    238            �           2620    24624    vid_strahovania ins_tr1    TRIGGER     s   CREATE TRIGGER ins_tr1 BEFORE INSERT ON public.vid_strahovania FOR EACH ROW EXECUTE FUNCTION public.trigger_ins();
 0   DROP TRIGGER ins_tr1 ON public.vid_strahovania;
       public          postgres    false    217    226            �           2620    24622    dogovor upd_tr1    TRIGGER     k   CREATE TRIGGER upd_tr1 BEFORE UPDATE ON public.dogovor FOR EACH ROW EXECUTE FUNCTION public.trigger_upd();
 (   DROP TRIGGER upd_tr1 ON public.dogovor;
       public          postgres    false    225    218            �           2606    16486    dogovor hranit    FK CONSTRAINT     �   ALTER TABLE ONLY public.dogovor
    ADD CONSTRAINT hranit FOREIGN KEY (kod_filiala) REFERENCES public.filial(kod_filiala) ON UPDATE CASCADE ON DELETE RESTRICT;
 8   ALTER TABLE ONLY public.dogovor DROP CONSTRAINT hranit;
       public          postgres    false    216    4726    218            �           2606    16491    strahovoi_agent sodergit    FK CONSTRAINT     �   ALTER TABLE ONLY public.strahovoi_agent
    ADD CONSTRAINT sodergit FOREIGN KEY (kod_filiala) REFERENCES public.filial(kod_filiala) ON UPDATE CASCADE ON DELETE RESTRICT;
 B   ALTER TABLE ONLY public.strahovoi_agent DROP CONSTRAINT sodergit;
       public          postgres    false    216    4726    215            �           2606    16496    dogovor ukazan_v    FK CONSTRAINT     �   ALTER TABLE ONLY public.dogovor
    ADD CONSTRAINT ukazan_v FOREIGN KEY (kod_vida_strahovania) REFERENCES public.vid_strahovania(kod_vida_strahovania) ON UPDATE CASCADE ON DELETE RESTRICT;
 :   ALTER TABLE ONLY public.dogovor DROP CONSTRAINT ukazan_v;
       public          postgres    false    217    218    4734            �           2606    16501    dogovor zakluchaet    FK CONSTRAINT     �   ALTER TABLE ONLY public.dogovor
    ADD CONSTRAINT zakluchaet FOREIGN KEY (kod_agenta) REFERENCES public.strahovoi_agent(kod_agenta) ON UPDATE CASCADE ON DELETE RESTRICT;
 <   ALTER TABLE ONLY public.dogovor DROP CONSTRAINT zakluchaet;
       public          postgres    false    218    215    4724               j   x�e�A� C�urF�	Bܥ�?G���x��4�[�F�lXj�,�Il�Z�3(3��J�dj��e�gtk?��&�J{��!ֵ"�	��/��=�~���&T$�         �   x�EPIN1<�_1/@�=���DpBB��ĉ��0̐���#�I$J�d����;��O����_���v�	{����T_}̩�`<!x���~�E����6�$��2�H�q���6;���M���o���ߝ��(��Z�3���o)��D�.��~�8TQB���Hh�F_u�b<k+�da������ΛL����E��f�.e>/�:�R4���0��˜           x�M�]J�@ǟ�S���L��]<LWP_��]ď�wKk���z�̍�OZ����Ot�g�u�ۑ��o��Qg�Cl��z�M|�A;�I_t��$΋�¹�<�<gzD�ɠ��$0���cܑ>�~��r�ߙL�I��JD�Q�Q �3	����}AKc)��Ù�MRk`�z 8%z�U5Y��g�T�������Ĝ�|��d�.�В�I[��q�5�T�,�������~���U����<SܦA+�
�n@�.-yH�f'\V�-g�WY��E���         z   x����P�ϳUP�)J�j�^�Hb+H|�'�0ۑ�=��7�j ;��Uw������{�����Ym�Z���7x�g.LְC��;�����ړ)�{���k���vp��J����TI7     