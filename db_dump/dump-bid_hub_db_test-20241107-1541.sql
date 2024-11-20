PGDMP      )            
    |            bid_hub_db_test    16.4 (Debian 16.4-1.pgdg120+2)    16.1 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16886    bid_hub_db_test    DATABASE     z   CREATE DATABASE bid_hub_db_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE bid_hub_db_test;
                postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                pg_database_owner    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                   pg_database_owner    false    4            W           1247    16888    enum_auctions_stato    TYPE     b   CREATE TYPE public.enum_auctions_stato AS ENUM (
    'attiva',
    'completata',
    'fallita'
);
 &   DROP TYPE public.enum_auctions_stato;
       public          postgres    false    4            Z           1247    16896    enum_orders_stato    TYPE     w   CREATE TYPE public.enum_orders_stato AS ENUM (
    'in elaborazione',
    'pagato',
    'spedito',
    'completato'
);
 $   DROP TYPE public.enum_orders_stato;
       public          postgres    false    4            �            1259    16905    auctions    TABLE     �  CREATE TABLE public.auctions (
    id integer NOT NULL,
    prodotto_id integer NOT NULL,
    tipo character varying(255) NOT NULL,
    data_scadenza timestamp with time zone NOT NULL,
    prezzo_minimo numeric(10,2),
    incremento_rialzo numeric(10,2),
    decremento_prezzo numeric(10,2),
    prezzo_iniziale numeric(10,2) NOT NULL,
    stato public.enum_auctions_stato DEFAULT 'attiva'::public.enum_auctions_stato NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    venditore_id integer NOT NULL,
    timer_decremento numeric(5,3),
    CONSTRAINT auctions_stato_check CHECK (((stato)::text = ANY (ARRAY[('attiva'::character varying)::text, ('fallita'::character varying)::text, ('completata'::character varying)::text]))),
    CONSTRAINT auctions_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('tempo fisso'::character varying)::text, ('inglese'::character varying)::text, ('ribasso'::character varying)::text, ('silenziosa'::character varying)::text])))
);
    DROP TABLE public.auctions;
       public         heap    postgres    false    855    855    4            �            1259    16911    auctions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auctions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.auctions_id_seq;
       public          postgres    false    215    4            �           0    0    auctions_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.auctions_id_seq OWNED BY public.auctions.id;
          public          postgres    false    216            �            1259    16912    bids    TABLE     �   CREATE TABLE public.bids (
    id integer NOT NULL,
    prodotto_id integer NOT NULL,
    utente_id integer NOT NULL,
    importo numeric(10,2) NOT NULL,
    auction_id integer NOT NULL
);
    DROP TABLE public.bids;
       public         heap    postgres    false    4            �            1259    16915    bids_id_seq    SEQUENCE     �   CREATE SEQUENCE public.bids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.bids_id_seq;
       public          postgres    false    4    217            �           0    0    bids_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.bids_id_seq OWNED BY public.bids.id;
          public          postgres    false    218            �            1259    16916 
   categories    TABLE     f   CREATE TABLE public.categories (
    id integer NOT NULL,
    nome character varying(255) NOT NULL
);
    DROP TABLE public.categories;
       public         heap    postgres    false    4            �            1259    16919    categories_id_seq    SEQUENCE     �   CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.categories_id_seq;
       public          postgres    false    219    4            �           0    0    categories_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;
          public          postgres    false    220            �            1259    16920    notifications    TABLE     .  CREATE TABLE public.notifications (
    id integer NOT NULL,
    utente_id integer NOT NULL,
    messaggio text NOT NULL,
    letto boolean DEFAULT false,
    created_at timestamp with time zone NOT NULL,
    auction_id integer,
    bid_id integer,
    "updatedAt" timestamp with time zone NOT NULL
);
 !   DROP TABLE public.notifications;
       public         heap    postgres    false    4            �            1259    16926    notifications_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.notifications_id_seq;
       public          postgres    false    221    4            �           0    0    notifications_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;
          public          postgres    false    222            �            1259    16927    orders    TABLE       CREATE TABLE public.orders (
    id integer NOT NULL,
    prodotto_id integer NOT NULL,
    acquirente_id integer NOT NULL,
    venditore_id integer NOT NULL,
    indirizzo_spedizione text NOT NULL,
    metodo_pagamento character varying(255) NOT NULL,
    importo_totale numeric(10,2) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    auction_id integer NOT NULL,
    stato public.enum_orders_stato DEFAULT 'in elaborazione'::public.enum_orders_stato NOT NULL
);
    DROP TABLE public.orders;
       public         heap    postgres    false    858    4    858            �            1259    16933    orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public          postgres    false    223    4            �           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public          postgres    false    224            �            1259    16934    payments    TABLE     �   CREATE TABLE public.payments (
    id integer NOT NULL,
    utente_id integer NOT NULL,
    numero_carta character varying(255) NOT NULL,
    nome_intestatario character varying(255) NOT NULL,
    data_scadenza timestamp with time zone NOT NULL
);
    DROP TABLE public.payments;
       public         heap    postgres    false    4            �            1259    16939    payments_id_seq    SEQUENCE     �   CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.payments_id_seq;
       public          postgres    false    225    4            �           0    0    payments_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;
          public          postgres    false    226            �            1259    16940    products    TABLE       CREATE TABLE public.products (
    id integer NOT NULL,
    nome character varying(255) NOT NULL,
    descrizione text,
    categoria_id integer,
    prezzo_iniziale numeric(10,2) NOT NULL,
    immagine_principale character varying(255),
    venditore_id integer NOT NULL
);
    DROP TABLE public.products;
       public         heap    postgres    false    4            �            1259    16945    products_id_seq    SEQUENCE     �   CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.products_id_seq;
       public          postgres    false    4    227            �           0    0    products_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;
          public          postgres    false    228            �            1259    16946    users    TABLE     �  CREATE TABLE public.users (
    id integer NOT NULL,
    nome character varying(255),
    cognome character varying(255),
    email character varying(255) NOT NULL,
    password character varying(255),
    data_nascita timestamp with time zone,
    short_bio text,
    indirizzo_di_spedizione text,
    sito_web character varying(255),
    social_links jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    posizione_geografica text,
    social_id character varying(255),
    social_provider character varying(255),
    indirizzo_di_fatturazione text,
    avatar character varying(255)
);
    DROP TABLE public.users;
       public         heap    postgres    false    4            �            1259    16951    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    229    4            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    230            �           2604    16952    auctions id    DEFAULT     j   ALTER TABLE ONLY public.auctions ALTER COLUMN id SET DEFAULT nextval('public.auctions_id_seq'::regclass);
 :   ALTER TABLE public.auctions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215            �           2604    16953    bids id    DEFAULT     b   ALTER TABLE ONLY public.bids ALTER COLUMN id SET DEFAULT nextval('public.bids_id_seq'::regclass);
 6   ALTER TABLE public.bids ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217            �           2604    16954    categories id    DEFAULT     n   ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);
 <   ALTER TABLE public.categories ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219            �           2604    16955    notifications id    DEFAULT     t   ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);
 ?   ALTER TABLE public.notifications ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221            �           2604    16956 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    223            �           2604    16957    payments id    DEFAULT     j   ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);
 :   ALTER TABLE public.payments ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    226    225            �           2604    16958    products id    DEFAULT     j   ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);
 :   ALTER TABLE public.products ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    228    227            �           2604    16959    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229            �          0    16905    auctions 
   TABLE DATA           �   COPY public.auctions (id, prodotto_id, tipo, data_scadenza, prezzo_minimo, incremento_rialzo, decremento_prezzo, prezzo_iniziale, stato, created_at, updated_at, venditore_id, timer_decremento) FROM stdin;
    public          postgres    false    215   /      �          0    16912    bids 
   TABLE DATA           O   COPY public.bids (id, prodotto_id, utente_id, importo, auction_id) FROM stdin;
    public          postgres    false    217   'L      �          0    16916 
   categories 
   TABLE DATA           .   COPY public.categories (id, nome) FROM stdin;
    public          postgres    false    219   �M      �          0    16920    notifications 
   TABLE DATA           u   COPY public.notifications (id, utente_id, messaggio, letto, created_at, auction_id, bid_id, "updatedAt") FROM stdin;
    public          postgres    false    221   �N      �          0    16927    orders 
   TABLE DATA           �   COPY public.orders (id, prodotto_id, acquirente_id, venditore_id, indirizzo_spedizione, metodo_pagamento, importo_totale, created_at, updated_at, auction_id, stato) FROM stdin;
    public          postgres    false    223   HT      �          0    16934    payments 
   TABLE DATA           a   COPY public.payments (id, utente_id, numero_carta, nome_intestatario, data_scadenza) FROM stdin;
    public          postgres    false    225   \X      �          0    16940    products 
   TABLE DATA           {   COPY public.products (id, nome, descrizione, categoria_id, prezzo_iniziale, immagine_principale, venditore_id) FROM stdin;
    public          postgres    false    227   �Y      �          0    16946    users 
   TABLE DATA           �   COPY public.users (id, nome, cognome, email, password, data_nascita, short_bio, indirizzo_di_spedizione, sito_web, social_links, created_at, updated_at, posizione_geografica, social_id, social_provider, indirizzo_di_fatturazione, avatar) FROM stdin;
    public          postgres    false    229   �p      �           0    0    auctions_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.auctions_id_seq', 3380, true);
          public          postgres    false    216            �           0    0    bids_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.bids_id_seq', 144, true);
          public          postgres    false    218            �           0    0    categories_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.categories_id_seq', 14, true);
          public          postgres    false    220            �           0    0    notifications_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.notifications_id_seq', 2188, true);
          public          postgres    false    222            �           0    0    orders_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.orders_id_seq', 41, true);
          public          postgres    false    224            �           0    0    payments_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.payments_id_seq', 37, true);
          public          postgres    false    226            �           0    0    products_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.products_id_seq', 1805, true);
          public          postgres    false    228            �           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 86, true);
          public          postgres    false    230            �           2606    16961    auctions auctions_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT auctions_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.auctions DROP CONSTRAINT auctions_pkey;
       public            postgres    false    215            �           2606    16963    bids bids_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.bids DROP CONSTRAINT bids_pkey;
       public            postgres    false    217            �           2606    16965    categories categories_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_pkey;
       public            postgres    false    219            �           2606    16967     notifications notifications_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_pkey;
       public            postgres    false    221            �           2606    16969    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    223            �           2606    16971    payments payments_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_pkey;
       public            postgres    false    225            �           2606    16973    products products_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
       public            postgres    false    227            �           2606    18638    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            postgres    false    229            �           2606    18640    users users_email_key1 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key1;
       public            postgres    false    229            �           2606    18642    users users_email_key10 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key10 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key10;
       public            postgres    false    229            �           2606    18644    users users_email_key100 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key100 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key100;
       public            postgres    false    229            �           2606    18646    users users_email_key101 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key101 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key101;
       public            postgres    false    229            �           2606    18648    users users_email_key102 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key102 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key102;
       public            postgres    false    229            �           2606    18650    users users_email_key103 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key103 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key103;
       public            postgres    false    229            �           2606    18652    users users_email_key104 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key104 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key104;
       public            postgres    false    229            �           2606    18654    users users_email_key105 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key105 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key105;
       public            postgres    false    229            �           2606    18656    users users_email_key106 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key106 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key106;
       public            postgres    false    229            �           2606    18658    users users_email_key107 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key107 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key107;
       public            postgres    false    229            �           2606    18660    users users_email_key108 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key108 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key108;
       public            postgres    false    229            �           2606    18662    users users_email_key109 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key109 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key109;
       public            postgres    false    229            �           2606    18664    users users_email_key11 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key11 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key11;
       public            postgres    false    229            �           2606    18666    users users_email_key110 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key110 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key110;
       public            postgres    false    229            �           2606    18668    users users_email_key111 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key111 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key111;
       public            postgres    false    229            �           2606    18670    users users_email_key112 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key112 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key112;
       public            postgres    false    229            �           2606    18672    users users_email_key113 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key113 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key113;
       public            postgres    false    229            �           2606    18674    users users_email_key114 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key114 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key114;
       public            postgres    false    229            �           2606    18676    users users_email_key115 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key115 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key115;
       public            postgres    false    229            �           2606    18678    users users_email_key116 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key116 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key116;
       public            postgres    false    229            �           2606    18680    users users_email_key117 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key117 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key117;
       public            postgres    false    229            �           2606    18682    users users_email_key118 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key118 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key118;
       public            postgres    false    229            �           2606    18684    users users_email_key119 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key119 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key119;
       public            postgres    false    229            �           2606    18686    users users_email_key12 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key12 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key12;
       public            postgres    false    229            �           2606    18688    users users_email_key120 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key120 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key120;
       public            postgres    false    229            �           2606    18690    users users_email_key121 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key121 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key121;
       public            postgres    false    229            �           2606    18692    users users_email_key122 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key122 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key122;
       public            postgres    false    229                        2606    18694    users users_email_key123 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key123 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key123;
       public            postgres    false    229                       2606    18696    users users_email_key124 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key124 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key124;
       public            postgres    false    229                       2606    18698    users users_email_key125 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key125 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key125;
       public            postgres    false    229                       2606    18700    users users_email_key126 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key126 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key126;
       public            postgres    false    229                       2606    18702    users users_email_key127 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key127 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key127;
       public            postgres    false    229            
           2606    18704    users users_email_key128 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key128 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key128;
       public            postgres    false    229                       2606    18706    users users_email_key129 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key129 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key129;
       public            postgres    false    229                       2606    18708    users users_email_key13 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key13 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key13;
       public            postgres    false    229                       2606    18710    users users_email_key130 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key130 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key130;
       public            postgres    false    229                       2606    18712    users users_email_key131 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key131 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key131;
       public            postgres    false    229                       2606    18714    users users_email_key132 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key132 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key132;
       public            postgres    false    229                       2606    18716    users users_email_key133 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key133 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key133;
       public            postgres    false    229                       2606    18718    users users_email_key134 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key134 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key134;
       public            postgres    false    229                       2606    18720    users users_email_key135 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key135 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key135;
       public            postgres    false    229                       2606    18722    users users_email_key136 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key136 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key136;
       public            postgres    false    229                       2606    18724    users users_email_key137 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key137 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key137;
       public            postgres    false    229                        2606    18726    users users_email_key138 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key138 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key138;
       public            postgres    false    229            "           2606    18728    users users_email_key139 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key139 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key139;
       public            postgres    false    229            $           2606    18730    users users_email_key14 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key14 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key14;
       public            postgres    false    229            &           2606    18732    users users_email_key140 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key140 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key140;
       public            postgres    false    229            (           2606    18734    users users_email_key141 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key141 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key141;
       public            postgres    false    229            *           2606    18736    users users_email_key142 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key142 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key142;
       public            postgres    false    229            ,           2606    18738    users users_email_key143 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key143 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key143;
       public            postgres    false    229            .           2606    18740    users users_email_key144 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key144 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key144;
       public            postgres    false    229            0           2606    18742    users users_email_key145 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key145 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key145;
       public            postgres    false    229            2           2606    18744    users users_email_key146 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key146 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key146;
       public            postgres    false    229            4           2606    18746    users users_email_key147 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key147 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key147;
       public            postgres    false    229            6           2606    18748    users users_email_key148 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key148 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key148;
       public            postgres    false    229            8           2606    18750    users users_email_key149 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key149 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key149;
       public            postgres    false    229            :           2606    18752    users users_email_key15 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key15 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key15;
       public            postgres    false    229            <           2606    18754    users users_email_key150 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key150 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key150;
       public            postgres    false    229            >           2606    18756    users users_email_key151 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key151 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key151;
       public            postgres    false    229            @           2606    18758    users users_email_key152 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key152 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key152;
       public            postgres    false    229            B           2606    18760    users users_email_key153 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key153 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key153;
       public            postgres    false    229            D           2606    18762    users users_email_key154 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key154 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key154;
       public            postgres    false    229            F           2606    18764    users users_email_key155 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key155 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key155;
       public            postgres    false    229            H           2606    18766    users users_email_key156 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key156 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key156;
       public            postgres    false    229            J           2606    18768    users users_email_key157 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key157 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key157;
       public            postgres    false    229            L           2606    18770    users users_email_key158 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key158 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key158;
       public            postgres    false    229            N           2606    18772    users users_email_key159 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key159 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key159;
       public            postgres    false    229            P           2606    18774    users users_email_key16 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key16 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key16;
       public            postgres    false    229            R           2606    18776    users users_email_key160 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key160 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key160;
       public            postgres    false    229            T           2606    18778    users users_email_key161 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key161 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key161;
       public            postgres    false    229            V           2606    18780    users users_email_key162 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key162 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key162;
       public            postgres    false    229            X           2606    18782    users users_email_key163 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key163 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key163;
       public            postgres    false    229            Z           2606    18966    users users_email_key164 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key164 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key164;
       public            postgres    false    229            \           2606    18968    users users_email_key165 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key165 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key165;
       public            postgres    false    229            ^           2606    18636    users users_email_key166 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key166 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key166;
       public            postgres    false    229            `           2606    18970    users users_email_key167 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key167 UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key167;
       public            postgres    false    229            b           2606    18784    users users_email_key17 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key17 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key17;
       public            postgres    false    229            d           2606    18786    users users_email_key18 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key18 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key18;
       public            postgres    false    229            f           2606    18788    users users_email_key19 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key19 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key19;
       public            postgres    false    229            h           2606    18790    users users_email_key2 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key2 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key2;
       public            postgres    false    229            j           2606    18792    users users_email_key20 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key20 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key20;
       public            postgres    false    229            l           2606    18794    users users_email_key21 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key21 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key21;
       public            postgres    false    229            n           2606    18796    users users_email_key22 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key22 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key22;
       public            postgres    false    229            p           2606    18798    users users_email_key23 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key23 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key23;
       public            postgres    false    229            r           2606    18800    users users_email_key24 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key24 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key24;
       public            postgres    false    229            t           2606    18802    users users_email_key25 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key25 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key25;
       public            postgres    false    229            v           2606    18804    users users_email_key26 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key26 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key26;
       public            postgres    false    229            x           2606    18806    users users_email_key27 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key27 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key27;
       public            postgres    false    229            z           2606    18808    users users_email_key28 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key28 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key28;
       public            postgres    false    229            |           2606    18810    users users_email_key29 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key29 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key29;
       public            postgres    false    229            ~           2606    18812    users users_email_key3 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key3 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key3;
       public            postgres    false    229            �           2606    18814    users users_email_key30 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key30 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key30;
       public            postgres    false    229            �           2606    18816    users users_email_key31 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key31 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key31;
       public            postgres    false    229            �           2606    18818    users users_email_key32 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key32 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key32;
       public            postgres    false    229            �           2606    18820    users users_email_key33 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key33 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key33;
       public            postgres    false    229            �           2606    18822    users users_email_key34 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key34 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key34;
       public            postgres    false    229            �           2606    18824    users users_email_key35 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key35 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key35;
       public            postgres    false    229            �           2606    18826    users users_email_key36 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key36 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key36;
       public            postgres    false    229            �           2606    18828    users users_email_key37 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key37 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key37;
       public            postgres    false    229            �           2606    18830    users users_email_key38 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key38 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key38;
       public            postgres    false    229            �           2606    18832    users users_email_key39 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key39 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key39;
       public            postgres    false    229            �           2606    18834    users users_email_key4 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key4 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key4;
       public            postgres    false    229            �           2606    18836    users users_email_key40 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key40 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key40;
       public            postgres    false    229            �           2606    18838    users users_email_key41 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key41 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key41;
       public            postgres    false    229            �           2606    18840    users users_email_key42 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key42 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key42;
       public            postgres    false    229            �           2606    18842    users users_email_key43 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key43 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key43;
       public            postgres    false    229            �           2606    18844    users users_email_key44 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key44 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key44;
       public            postgres    false    229            �           2606    18846    users users_email_key45 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key45 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key45;
       public            postgres    false    229            �           2606    18848    users users_email_key46 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key46 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key46;
       public            postgres    false    229            �           2606    18850    users users_email_key47 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key47 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key47;
       public            postgres    false    229            �           2606    18852    users users_email_key48 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key48 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key48;
       public            postgres    false    229            �           2606    18854    users users_email_key49 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key49 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key49;
       public            postgres    false    229            �           2606    18856    users users_email_key5 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key5 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key5;
       public            postgres    false    229            �           2606    18858    users users_email_key50 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key50 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key50;
       public            postgres    false    229            �           2606    18860    users users_email_key51 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key51 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key51;
       public            postgres    false    229            �           2606    18862    users users_email_key52 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key52 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key52;
       public            postgres    false    229            �           2606    18864    users users_email_key53 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key53 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key53;
       public            postgres    false    229            �           2606    18866    users users_email_key54 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key54 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key54;
       public            postgres    false    229            �           2606    18868    users users_email_key55 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key55 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key55;
       public            postgres    false    229            �           2606    18870    users users_email_key56 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key56 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key56;
       public            postgres    false    229            �           2606    18872    users users_email_key57 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key57 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key57;
       public            postgres    false    229            �           2606    18874    users users_email_key58 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key58 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key58;
       public            postgres    false    229            �           2606    18876    users users_email_key59 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key59 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key59;
       public            postgres    false    229            �           2606    18878    users users_email_key6 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key6 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key6;
       public            postgres    false    229            �           2606    18880    users users_email_key60 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key60 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key60;
       public            postgres    false    229            �           2606    18882    users users_email_key61 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key61 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key61;
       public            postgres    false    229            �           2606    18884    users users_email_key62 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key62 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key62;
       public            postgres    false    229            �           2606    18886    users users_email_key63 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key63 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key63;
       public            postgres    false    229            �           2606    18888    users users_email_key64 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key64 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key64;
       public            postgres    false    229            �           2606    18890    users users_email_key65 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key65 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key65;
       public            postgres    false    229            �           2606    18892    users users_email_key66 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key66 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key66;
       public            postgres    false    229            �           2606    18894    users users_email_key67 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key67 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key67;
       public            postgres    false    229            �           2606    18896    users users_email_key68 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key68 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key68;
       public            postgres    false    229            �           2606    18898    users users_email_key69 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key69 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key69;
       public            postgres    false    229            �           2606    18900    users users_email_key7 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key7 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key7;
       public            postgres    false    229            �           2606    18902    users users_email_key70 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key70 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key70;
       public            postgres    false    229            �           2606    18904    users users_email_key71 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key71 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key71;
       public            postgres    false    229            �           2606    18906    users users_email_key72 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key72 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key72;
       public            postgres    false    229            �           2606    18908    users users_email_key73 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key73 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key73;
       public            postgres    false    229            �           2606    18910    users users_email_key74 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key74 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key74;
       public            postgres    false    229            �           2606    18912    users users_email_key75 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key75 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key75;
       public            postgres    false    229            �           2606    18914    users users_email_key76 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key76 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key76;
       public            postgres    false    229            �           2606    18916    users users_email_key77 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key77 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key77;
       public            postgres    false    229            �           2606    18918    users users_email_key78 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key78 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key78;
       public            postgres    false    229            �           2606    18920    users users_email_key79 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key79 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key79;
       public            postgres    false    229            �           2606    18922    users users_email_key8 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key8 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key8;
       public            postgres    false    229            �           2606    18924    users users_email_key80 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key80 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key80;
       public            postgres    false    229            �           2606    18926    users users_email_key81 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key81 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key81;
       public            postgres    false    229            �           2606    18928    users users_email_key82 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key82 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key82;
       public            postgres    false    229            �           2606    18930    users users_email_key83 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key83 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key83;
       public            postgres    false    229            �           2606    18932    users users_email_key84 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key84 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key84;
       public            postgres    false    229            �           2606    18934    users users_email_key85 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key85 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key85;
       public            postgres    false    229            �           2606    18936    users users_email_key86 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key86 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key86;
       public            postgres    false    229            �           2606    18938    users users_email_key87 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key87 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key87;
       public            postgres    false    229            �           2606    18940    users users_email_key88 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key88 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key88;
       public            postgres    false    229                        2606    18942    users users_email_key89 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key89 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key89;
       public            postgres    false    229                       2606    18944    users users_email_key9 
   CONSTRAINT     R   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key9 UNIQUE (email);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key9;
       public            postgres    false    229                       2606    18946    users users_email_key90 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key90 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key90;
       public            postgres    false    229                       2606    18948    users users_email_key91 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key91 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key91;
       public            postgres    false    229                       2606    18950    users users_email_key92 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key92 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key92;
       public            postgres    false    229            
           2606    18952    users users_email_key93 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key93 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key93;
       public            postgres    false    229                       2606    18954    users users_email_key94 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key94 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key94;
       public            postgres    false    229                       2606    18956    users users_email_key95 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key95 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key95;
       public            postgres    false    229                       2606    18958    users users_email_key96 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key96 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key96;
       public            postgres    false    229                       2606    18960    users users_email_key97 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key97 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key97;
       public            postgres    false    229                       2606    18962    users users_email_key98 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key98 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key98;
       public            postgres    false    229                       2606    18964    users users_email_key99 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key99 UNIQUE (email);
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key99;
       public            postgres    false    229                       2606    17303    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    229                       2606    18981 "   auctions auctions_prodotto_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT auctions_prodotto_id_fkey FOREIGN KEY (prodotto_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.auctions DROP CONSTRAINT auctions_prodotto_id_fkey;
       public          postgres    false    227    3270    215                       2606    18990 #   auctions auctions_venditore_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.auctions
    ADD CONSTRAINT auctions_venditore_id_fkey FOREIGN KEY (venditore_id) REFERENCES public.users(id) ON UPDATE CASCADE;
 M   ALTER TABLE ONLY public.auctions DROP CONSTRAINT auctions_venditore_id_fkey;
       public          postgres    false    215    3608    229                       2606    19005    bids bids_auction_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_auction_id_fkey FOREIGN KEY (auction_id) REFERENCES public.auctions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.bids DROP CONSTRAINT bids_auction_id_fkey;
       public          postgres    false    217    3258    215                       2606    18995    bids bids_prodotto_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_prodotto_id_fkey FOREIGN KEY (prodotto_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
 D   ALTER TABLE ONLY public.bids DROP CONSTRAINT bids_prodotto_id_fkey;
       public          postgres    false    3270    217    227                       2606    19000    bids bids_utente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_utente_id_fkey FOREIGN KEY (utente_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.bids DROP CONSTRAINT bids_utente_id_fkey;
       public          postgres    false    3608    217    229                       2606    19017 +   notifications notifications_auction_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_auction_id_fkey FOREIGN KEY (auction_id) REFERENCES public.auctions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_auction_id_fkey;
       public          postgres    false    215    3258    221                       2606    19022 '   notifications notifications_bid_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_bid_id_fkey FOREIGN KEY (bid_id) REFERENCES public.bids(id);
 Q   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_bid_id_fkey;
       public          postgres    false    221    217    3260                        2606    19010 *   notifications notifications_utente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_utente_id_fkey FOREIGN KEY (utente_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_utente_id_fkey;
       public          postgres    false    3608    221    229            !           2606    19032     orders orders_acquirente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_acquirente_id_fkey FOREIGN KEY (acquirente_id) REFERENCES public.users(id) ON UPDATE CASCADE;
 J   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_acquirente_id_fkey;
       public          postgres    false    229    3608    223            "           2606    19042    orders orders_auction_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_auction_id_fkey FOREIGN KEY (auction_id) REFERENCES public.auctions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_auction_id_fkey;
       public          postgres    false    223    3258    215            #           2606    19027    orders orders_prodotto_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_prodotto_id_fkey FOREIGN KEY (prodotto_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_prodotto_id_fkey;
       public          postgres    false    227    223    3270            $           2606    19037    orders orders_venditore_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_venditore_id_fkey FOREIGN KEY (venditore_id) REFERENCES public.users(id) ON UPDATE CASCADE;
 I   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_venditore_id_fkey;
       public          postgres    false    3608    229    223            %           2606    19049     payments payments_utente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_utente_id_fkey FOREIGN KEY (utente_id) REFERENCES public.users(id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_utente_id_fkey;
       public          postgres    false    225    3608    229            &           2606    18971 #   products products_categoria_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_categoria_id_fkey FOREIGN KEY (categoria_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE SET NULL;
 M   ALTER TABLE ONLY public.products DROP CONSTRAINT products_categoria_id_fkey;
       public          postgres    false    219    3262    227            '           2606    18976 #   products products_venditore_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_venditore_id_fkey FOREIGN KEY (venditore_id) REFERENCES public.users(id) ON UPDATE CASCADE;
 M   ALTER TABLE ONLY public.products DROP CONSTRAINT products_venditore_id_fkey;
       public          postgres    false    227    3608    229            �      x��]ۮ�6�}�|E�1t�.�#��%3H
Hw�`��K�lʛ�U�h��8�֑(^�CT����?�������|	.�_��ŵ�}zyzŰ��Z��p����T��������ї��������~��������o/��>�iL/��2�?����AR](m�b�K���Gy���(RZr� �X
��(P� (�)+�����S@��vd	Gt@�J��ͶC�����Og ���+ �##�Ȳ*��/i�P(�]��| j��m�
v�. "*��V���92	��ء�RT�by �,�ε��B���lGVqd�
�P��2�=T�8��G��qd: "\�������P����j U� FW�3@��#+ ��>�+G�B�E�/���~�i��j����t[r��w+�Q��ӡ��E�4[I����T@9��Ʀ��QCP�l+,G�-Gp���b8l+�C��C��v|@%��]�"" j"��HǵO�����,�:�̜~f�貱E���S@�T�|2 ]S뀨��ǡ)����,�}�9����7�B]a�n�I�軱A�X�^,�^�����2�n��(uE��K81]��튱ݳ �e�2��2Pt��>�OK���f@Y��	���>귾-��������Ճ-��1:ǀR� �_z��,ԇ9����׿�����F:DQYӣ2�n������Ev��xC�ŏ���7L9R�F��Qk_�������b�޽R�P�Y��� ��i����w��Ԅ_V����D�.C!朰Q�䰟�"�BE�Y��8��X��4%�{�d�=�@�E��#�GhVz��b�l�����\G���zM�ٵWdg����3��hT�S�W�߂%>A�э��+�+��Ma�k��	J¦��w�p2Խ��
'�A?@3��>a4|BML	۱�MH�h�̶4��h�p5�(.eت�{s]K45o8,�R�rS�Bco�kk�h�;�9˄<K3�M�N*����{g3�/[���Г,�H;偆4MES�qR�.�����w4l�Eݧ�����J���p�L	0yU���p��.��5��q㜼+H$<�o�t�!��ZN�Xi��QV}�p��	)̪��U����xd�r�׎k����}w���qHF�IX�!�!ђ���f�䛋3�3���U�8�V�S!�TG2��8(M�9t��&�#���\4U������ac)g��)��1� I8�d����I�hrJ2��8���J?)�9��U�Xo�	P�ٝ�k.b7�k�Q����h�,
D���f�ח�����]u�p�n��*�HU��,i�.����\Ŧ��f�f4~�����{�9ti{
c��X��vͳ8��"3�:�k:���$9���	�8T�U���*��jf7��;b�cq��c}����{�g��I�b�.�I��A�#���n�Zж���m��e��hJM��A �@����A�q�~N������/A�(�1jY��]f<å|�&��� ����
B�Q?�(�?@�f ��[���Q�D�}eh��A�E焦y�m2�3jkzʶ�#!�ZXʝ�����@�x��J����貱:�2х����E���z\�����u�wu��Kw�B|�QOW�!%�����F#=/B�Ќ˕��I�ayf�L�/W����;���HJ���+n��&�|T�J�W=���� �+W]ES�x��s�w1CzӤ��0W�0W�AU�;�a�-���M��1��`3*�k�r,k�p�^	4�Ea��$=I�s�
�G2'���NI��c5�1/9�MqHB���� �f�E��+��Ca��cD������N,i�Xݐ��s�|�������JE5M|;I�ǅ�t���|L�e����-~����L�T2�U���D���~�a�O��*r �H���Om���KH�%��2J���=����'&��k�c�h4x`:��7��:z�ϸ�kyd�h��h�T*b�͞�V�Eؕx�<10��� �y`���+RP�hWU�t�5V����	O�|��ӄo�`5�QxTu"L�#���J�ό�#��%��z�Z�-i�wX2�$��yÐ�KjbΤ\����]���Ox�bNj�����<�(��[*h�9�+ ��ց�;�.��#6N�Z���#59��@���Itć������V�,�U2���q�g@��p���X�MI{E�e�G‭Vc���8��⨞�#4�*\EzJ�[�c���#}: �<��P<T����
���'��ԧ�S����BRS
�X�^ZJ���S@�H��%��h1�tDU�D2XrOy�M�b�bz���!���]釮��w��oo��u<>;��oϓ�$�U�3�A�Ы���ґ��������6pb�R]@�d��F��) Y� �,��C�ۍK�(?O���Jŀ ]Jl�m4�t`@�i����葈&+�35�ݨ{���ԔO�.3+!�BV����X�<���K���\+�����Z�bX�����n����G�AF��KP����`7�ӌG��T���Z�6	�����|�Bx"�6=��Dj��$3�K�]0� �Ї�`�����H�j��R#7����g�)��P�T�t�۳�������QZSD��8(uk
��{&��4o	&x!è+��y��̶j�/8 y�	�&=1tM��5�f{ob\��8Q0G<2ddd�t�I��Fa���9�Iiڜ��1�w����_ҸT��M�!9{i�h�L�F-�Xh��icD�7�F�9�M�#$+T��p����p���S��i��D��ڑX����y��w�Z(�7��d�hXPv}����7|F#�u�p��AGUє�R�v���~�'0T��B7�H7��Kp�.�LO�� iՠ�J)4��U��4����ld5���O�����꼷Gu�ސ�p��{Z{�ׂF��5�:BN��5��J����h.�*������'eqcu>a�G�\���h��R�dR+�&�PЍ��˜	�JjO�Z0:����}{$y��Ԥ�шT���Bp�U�V��<_D�ăA�X�ܞɅ�|Zcϓm���O����qzV���IC2�d,�&o�(.j�3LT&<�L�Z���W�v�'`�g�n-R��,4y鶭)��4)ț�s2zUu�IE�$Ы�8��Eף]��vUPh�P<���ǹ��&DWm���XA:�Fq1?���Q8f4��աA&;�����Л��Ed0~���3�H��&�Љ�&������\j*A�lG�+?��V�h"��J�f*����
c��:�0 ��[2R�,�{	C����g@Gv��3H�3�#æ�qd�/��x� d
��if��m�70ht�Kq
m��#�GW�5��!XY5.M��T.��۳p�=��CP���}7�+:��׾C1�{��&@$v�'��OƘ�u��򤧃ԚI�V!#�bR�G6.�|��:�-�nJZ�*i�|,�E������:񱤏n������t�x����E|B�~_2�}�XG=����S�#k�֬�#즣�[���(�d����1O�ǔ�έyJ8J"��Q�"�����{>�Z�pJ�6�iSC���!X��sh0��F�v�b~T �H5��[�8>ߚ�:*Sd�8��������a�)d�앣�5n��Aj�p쌬�B7eh jN�+z0��㈟s�0����d��`���g�t�O�c9�ܲ�g�cY���9a9)��=���E�rD�<Ge���B����&��d��@�����_���K]v=��hj��{������!�a�u(�$���*��
�f�15\	B�?�m��0�2�o��Mx3xX2+�����:�N4
��
�_����[�����֤xv����?��������Jr������߀��8�]�������	B�fA`��:~�.��s��L�i��3[���_�'A�I� �c����{hy   �
$���M����8Ep�� 	�E�Em?Ŗ�7`��A�x�ev����@0� ���Ǝ\^�wB�q�3�  �]:��>�����Q�TiL�;=Z�c8>Uf��B �nJ�g$�ݽ�0?�J��r��f��@R_+)C �o��^eI
��%����8��d��j�+yɵ�{��~(�U
/�Q0Z�ڥ6H���%-wg��+�[b�n0�!�U�_I|��*�8�������uF�d;"������1�&�����x��ϛkCN�vl�X�mN���`�(���M~�Xҥ������K���"$cIDJְL��-���x'��Nn$m�V�ZEtF+ڳ(��km�'�<8�%���Mđ�9��M�h�wP����������_���W�����f]��F�O��5Xrj6 �z$�lVO'��.:�ڻ5��!��g�M�YZF�G ��t�&G!�����I2{��&Y�U03qP��S�d�k�u5LF���x��6yw��M��)Pi�E�Uɫ���GwF�hĜN���gM��Q	��qR��=bh�Fj���K`r<2f�.��9�i"����8�ҹ��r��l���:q��u��!����
�':7TA�Й)�J� <zW��o8C��{xv�l�lO�����=;�flޮ�o/������yr�#$�臭�Ϡ��c����=�Ȳ�EfLH���F�(_�v�z1��CH��j�@��GE����׃�����ImB4�J��i�������ţ��Ԯk\!�$�/=t����>��:1.�c�Y#IU�e^��nh8&�8!�<�o*�"��O�x������h^�LL�����������΁|Xs%��yV*����+����g*b���wȮ�3�����Rx��JDV���C@�>,!�A`@���M���?�0�	P0h(Z�nl`ߩ���9� ���'�;�!��QX\�?J��^8u�|·�H9�h"���`��r�C���{����N6��G7���748��pL��4�^22l�{@d{�����ѫӎ^<t���	L��=z8�������=�]%Y}�f����1ͺczKTz�<ƥ�����=�K�"9`as�]��<9�ݭ�RtzĎ+�� �"���A�1@��w����g��� �Aκ%�� �d-ѧw0$���J��Y����I�fl�7����}��:	ߜu[zA���.��r�G�=0r�Ҭ�һ�+�m���I��L7I�\tCzw}B1�WmЂ�L�Ê�dE�E*.��\�=jk(2�D��W_&�캏�A�V��d�\~�>��s,����3��X�H�B��>�Gܶ�&�l��A^� ��Hgu� ��`���Aԧ�IeDP���!(����@K�I�a9��g�*ԥ4A뀪D�2*ge�=N�G�D/�z0����X�HuRF�hd���[�=���hJ.��}�)�!�r�(���ou��AT�o`����6@#Z?e�q��yu��ط!���>�b2�Ԣ��o�� cފ}�2��>6����ZP���$:B5�'C����N\�&��K��0�!��B ���za��S�
q^��D��_a��F�x%�K6{�ڝ8�I�����
�[�}S����m���ks̏
Q������� 	�K}ZbL�����"�SD�I	F�z���TQ�p/�ߊ��3��{�/2���[T��x��Do��R�� ���l	�'��_�׷����׷q�;����!����c}˽|^B��8���ڄ��ý_��
���vAM��.�,��;�+�J�h�G�O�T����_�_�oI����A��2���a��+����J�������%�0a�\$%�_ߊk�wi��?g���M�-�O�&SrU"롨v^�|���(�����vEդ��	������AY����=��_��V�N�/�{�*��X������,������x��U��o.�Jj������:o�)����?���Z�&�8����O�2��'��q�H�4e�{�OS�i[�?;	����NBӝ������g�I����4��~����(]�������'�zzI����ܛ�TO(vN�է�Ǫ$��׷���8_��]�4�� �s�>�W���1��������Px���(tO M��%%�3Pķ�!�M �B�n@�,���	A],��0[ۛ��X*��
o�,.I�ic��w���I�h��o� A���@A/I�B��s��YqD\�C@��,��˖�����x��������=�7C�}i��	
yͨv|[u��
��Q�"��%�f9M\����X��B|��<�~>8�I�itT\���3���HV�N�ڙL�L���|7	�1���:?b��w3�a���L��m������a�O뚣�9R��|k���t�մ��� C�����ICb:_�玃�kko��1��
�l��*��Zt���d~h��]'����s���ZPP��M0�lw篐��t�I����6�yG�ڐvA:22M�q��f��#�6A��G|�F��!\4=��&��#(Ovo'��O�8>߄�D_�����"�j��1|V��ܨ�[z�w�-ׅG���)@,5��x�J���#���~����~��S4~�x������)��:=ɯ���$P�g_�ڟ��0G1�E��
>n��xpG�ƥ/�tm��=��L+�s4���Ë��[o���O=��9�_Z��O���1��� j,��xj����ʧLs9�h�{���uM����n2�L�CZ\������®�����.�����"�~�u}���A�(UM��i��J�4J6~�5M��@Ԓ�X�o��+]I�e#(%���w#+_X�&aP�~�%��F�c �6,j~�� |7Dal5�iE0�u��(���7A;��%�j��$>��'D�2�k�t�|Cd_��ce-e )�bå�{�~%��_�Z�Z�������d���-���o�жb���M3
H��a\߹❬ z�X �"�C�}0���!�������Gi��Չ�d.U�����}\!�bB(����ti�y㕵,���ԏXx� �=���z$���\�8 �_���跶J�Ɖ����$�:}Hdh��Du��7��\���ޓߠ�0�v[�	W������W�a��ũ�G��Zϸ5%�j��y�~���6I�o��>n��'=�+:+�5�Z�U�vxK�N����k�Yu�ٿ?Z��o�O?���\�k�      �   �  x�U�ё#1��!�-�\.�8�{ly��u��Q7^i]�k^1.[�o���3��}^��������lKLphc����!c�3?�߰�������%Q�~���M^���謒J��&i���������S�MqO���%��ڇ�$[���NI�L�K�-svޒl���Rl��Y��2��IY�)��Sԝ}�򭴦�{�M�9�uC���1�!뮤�p�fȺ�]g�k���\W]�{�m���3�M�N.�ﴃ'y�!�>���̸dm�CT��LR�I�>��D�\�!�$Z��IK�`?I��C߹�X�XO��	6���d�O��X�q'�ތ�Ɩ���Ɩxo60[~���G�������0z���|3{~�3��ѫ�	�qF����}kc,�}s[�,1J����=�ͺ      �   �   x���n�0Eg�+�E%mc�]t�څ����d4���Ke"py'�ٜq��µ
��۴�]�Hiֺ(��UG��8;'N7���=�������N�4����ΫkhM]���T"��@�D��w�k��u��`�Xy��e<�y<2��j�y�u�B/�&�u�*����d��Y�q�/�&E�����P?      �   �  x����n�6���S(�,�"u��έ�I)
̆���,�좳�t�E�bޤO�sd;х�����|x.���Y�5�$_q���9y�$�<���LD�M����HȋVs�犬e�-��sI��C@	Z>��?�֣��Pz�x���ϵi��8��/��.8b��@�+��x���ϯoo���drCf*%��x�,�����86�5| _�kC( �u�Z��z�G!�L h�-$W�"� �Z$��`p�����P �W\����$9��G��;��vW)�r�J��Ed�*}��5O䜿����6���C��-��
�;<0vìx��g�*�u+������|�]j@i ŏL�T��e.����\.+<-)�)(��E���* ���H�*�S>{���c����=S�5�~"ndS���,�R<��=�Ȋ�eak)��҇�����j�7�$�L.M�c��8n-�� ����<���Y�R_U��'��������c�8m3����a���9��3�$�$��׍������)�R2~e��5馩o���������.�c:Ѷ�m��kg>�+ƾ�+���y&��9��؇܁��.5]oC����,n���4���n�halrk�s��-�M�>UI��"/�$_�4�}�͠�\��٘�HZn�-O����WP~J�K�w���uQNV�-���D{&4w�� 	c�u^=s������q&�~I͋D�8}���A������rNF�ًi.���GM����֯r�y:����Ϟ1�;IM��̢���_^����
���4��� 9]�:]��֢)݊��r5��ܗZ�CM�ޅuw�amągP��y`gb��k�;%bG��;O~��i.X_\x��o�gU���Y'7��!9�z8��[��I�<kC���C�b���1�L��܎�n��|Q�Q��� \�͋ħ-�EU�����O�˼{^X�R0;
[Y�M-������d��L7��xS�-pU�E�p�*pt-�R E�D��_ fl�]�����*�ո'��%\n�3.3��� ���g�r�#r�҂L^�\�kpm���K�`�!����*y$��jJ���Sj���ںܔ�ʺm�H>2�0&�P/�\�t�/���ҡ,@�x��ih3��^���*c��;_G_k	���˼�  #���n�b��D�n�ۏ�����w����H��xOѴ��a��=���D��� 2��.��!�O������o�$�s����I��JD��k�=22u�� A��u��jZeY���a�L�s���������n_	Ż
��p*�_|y�êS"����5���)]s����T��g�v�S|{�/�
�7����He��9TQυ_��o���}hO�nG_�����ҟ��      �     x���Mo�8��ί�yg+����0��b{ڋwZ�� 詿~H[V[za�G�x_*����?ǡ�{������p���c����z�;$k��Т{����3%���v"�!3ZCa
��~���x�J��QI?Ə�d��Əc�%��!���Ar�!�\Ey�2��as�)�����U�r��Wq�U��^����������|�x��M�S66�o�!��bv�0A���V�|�`��g�&ڲ�d��af9[Y�,�4�I�������T*+<^V�Ѷ��јٙ�x��Lr/MM�O����=����@�A�x�@�٥�T�N��^��ɢl�x��DM҄%UWY,�`O�t�R�����&D�$_�,X�^�pw����l��7�T線E�ݪ�ʉ��m��B��v�j�,u�@O�%�3C�֬)�A�8��jA�	��6~���Ƃ�P20ϖ��ZP�oAMe�ƅͰJ�3�᥅\-Ղ�=Z���KUZ��n�2�X�K�\]	Օ�=W�aE��IH|����\-Ղ�=a�t��/{�2����tyb0��XP-(>1T37���<_�t3$��O�����x�����bOAv���s9QN��覭�ق�+�����#{�~:�ry���J4���2�^9v����?�6�
�:>��$T}�����Y�4�-�5ǩX�n.rI����A����ѵ+/��)��q�e�rh�C�I>^֞	���P�LI&pܭ�]s������&�B����!�r�J�<���0�w^�$ٰ����`�Ǡ���q1�9ш��2N9���5���6��K��6�@jaWK����N!��K��H5��ڹm�$�C7��݄���Ň��:�l��`om���X��A����Mm"��wݴ�A}����/�<�U����	��h^[���8N}�:���k��8nը�Q�(>�M���j�3����ȼ��֒�$�Zſ�p8��573      �   G  x�]�1O�0�g�Wd�I��lpܱpHL,Q�"���_(:�S���߳��p�GH��ů��sN��sv9�V�����	�n�V�Ѡ�Ip�.N~��8+�Je$6`lH𔲏_I<�e����RF��2�%5+!:�ֵ�F�N�fd#;<�iryNb�~�5��9�Q��`mI����2�~�4H��g`O"å�$v)�-��d��H�_�9'��f���#��I��>���h�6 b-Q=vÀ�;�s�#m��-&*�G[@��4�k�{�K)�.�m�Z���`���WOr��w��D'��UFQ�sm.�n���^�      �      x��=�r۸�Ϙ�@�Vm^��H�<Z��hַ�<�n�@",�L: ��k�a�?Ώm7HI�n�N��CFݍF�/�n��������r���I���EIRY̌��t.i*��80�#�`�y0 ��!��/�9�<��Be2 �����vi�� >�o���m ڤ*��"�e�[TĿxq%�|'��E)�o9����ī6�
S��T3�IQj�
Z��I,t��V|�F,�F2/E�`�R�����y���L��U[ť6J4�2��t�o�`mALJX�e��� n��Lns��5g�s��xj���lkSX�)����������@ڳ�[D9װ��)z'M&�����B�͕V�VM������m�s��Fd
����T�0vL:{Vt&�LЬB�eJe&�"�!>�<$	k�`H#�F�`N���%��B"��#A:Br\J5`2�uDx<p�'6�HpC@��!"�.'bW*���'ezَ8i����6p!W8�"�'<�!������2�U���DxxHc��/*�aPW}p�yaC�����`�.j�]������Kiž�Q�A�]N���b�s�`�Dc�3U
�zQ��h���X��4"K{ћ-�H@,�%�H؋ #	z�@���4�,,`��d	f<����I��a�ρ�zWۿ �9��1�F����L8!��Lys�UV �\�艎hM�Ԅ�⒪��ՠ7�U�j�KBo��B��8zj������Y
>��xkIТ-$��L�9q�j�Hr��|ٕcƁ�p@e.�ݲ!x�jc�;1j��}rB�"e�j�,A�e�N�D���a�25R��z������;�82���*Ũ����Wi
��q���:IH��*�лg���R��@UEO���bת�m�R���wj^ɒ��7��[�қ2���k�� "��cm\B����6e)d_D$��������`�/���F@��#�
9��ӕ<�UV����x�t_v�c�`�|���.�P�����ܠw�ȣ �l��;�y��A��#E_g�s�20r���eA��t�uTˑN&R�h��)���X�=l��2W�3�̀t��d_���{��?褚�����kW������4wr��g�vo�[�ը��m�nk��{o=1Z��~���X�/F�3=�U݋z���=�e&LB� ��r��-*0�s��J�*2mdm���K:�UA�v�o�nD�l�+�.�5���0�y�=�E�[+�w��K��Ui݊��?l�\��.kث�$v�m����<��L�^�z�sn�X�V;�#��b�j$8�������Q����cǟ`��z�e����Ǝ)`^k�p� f'x'�d�_�E��P1S��ĿX����8ؑ�#���ށ��V:�U�m�E�^U}5���E:�G�QV5y!��`��P+��B���T T�7�����lܖ�A���O�e�w��r)
4��!J���$t����,U
��u׈�5b�^N��ӵ�'�]m��J����T�z��<<K:�!`O�4��k��t��+0|g��e)��o�[���&ڲ=!o��Bϻ��1�|�o
F���=A4ҡG.� E�:��$��A�_��[݊w�;�V����o�/�H�EǞ�lFn��ʎ��GN����\1]2Y��r�faHn�.�)9��0qw9"CQvn������ISm�6�x��:o�*g�%�9(�۬� �g3Vd@�%��
'y��`	$�*X�)���I����;m
�h�y���ۑ눓_ż�^~zx[ʮ��j��ֻXKi���b�;F�w�#rQ�58���7�w�蓐9;��Wa2���f3
@s�A���������dOY����>i���b��®Gz6��fdڵ�-�*�������A���Ǽ���q�h#����\[$vF.��n�Ҳ����3��:��G��K��)-̨QSa����MX�ӛ0�xCL�MJ�Q�:?5��Č�?�W�3YB�n^� u-���ۘ��&`����}�cw���h	 >a)���s��j�8"_���(��ЍVtL��GB������5��m�/��k&��z�vȏ�U��\i�9��l;&�{�E�W1=fT�L�����$&�Gn��02�*���M�۳*%���H	��&���kIz�K���}�]�<	Ʌ0/�F�a��e��SoÒ�ܩ1{��8��)mJ�k2ڗ[ILF"OE�T����P��mj��kr|>p�"!�B!S0ɤ�D����ot$�O��T	��S��2�����sZb���<�����
K��;������F�\�<��Y�-����)�Ⴠ�� ]���4i��0T�}��֖�n�U�)�J����Z]Hw���t��4z�>�}���7g�!�
��]��Z<0o;���_�����4��䀿��C�=Sy�s98�_��}!�K�l������C��U���R/��V�P�ڷ�x���� ��K	�(؍$ <Ȥe�fd�Jb�5��F��̞�-'�J6�tX��u
�u"��0��N�`�ڀ$�s��F@U���
�:Y��`�xZ<��2C[��s�n����!�Щ�-�Qi����E�U5ϱ4�N�Bu��uZ%Bܘ
/B�jʝ��.�ǉ��d�2T�,��F�w�-��`v\��$��/��!��9��.O�"�Q �s���R�sE4��2���[���lG�c�v����u����ɣq� �����jU�ޕn[;�]5˥��|�N�)��M�X�%̗���N��c'v�XN�?i��t%�Q�+��ZJt��E6S�lj0$�Ex�ͨKml7�i�mnŀ���I�Y&a0ĝ�#j��zy^! ��z҅J<���s8sK�P/��7ó���t��s���W����L�i*���GN��!U���ᅜk������A���}�q�͢)�:���o�x�d�aQ-_��E�uN¦��C8!�nI1F��4$a䈃-.��S�f�\�Tt/<v�"��P��Y�Q�_%x"�{
�N-�d��'z�US���0��i�9����2_@?N5F�:�_��/��]�<dd�^$����,�"�y��`��
9��u��	Oȃ^Сigԩ��a��<��ߵ�C��ne�յ���%,���U���Dw�)N���r�my�P�b��u���WVk�;pr���.e�!�)j_��V�P�ֲ鶢�,�ƲN���V��(���NGv�6�C�K=7���l\�(�B��G!���U9�5�4��9=)<��B�h�W9Կ+ٗ�p����`�[�F����ie����I-�(�/5w:F��'���S���9�~��1n1p�0�4�t6�p�֚�W�9Rt����rgd����.�h�^�����A3�	1�>ٜXO��]kKW�_�nԋ���t��P��ٺ+���r������m��P��� `�U��c���}i�(q<�����h|5������ߏ��oo.w^a�q�9�uAU_"�8m��)֕]I8������Ƚ]I���H bf�1SS��N��؃b�-V��j��a�Ӏ�j�U��B�*?[U� ����V� P }�8p��Ķ�O�<GD)�}P{׭ޟR��D�!�d�Y����t�/��Il�5�$��>�j:���Q�T����#���'�j�z�	l��{2}�ڞ'1��6�gU��߃@6h�$>�5׶X
�~r޼-�7 4vB�>��5��(������w���#�z�F/T������<���p�c���]��[|_�6��Rǀ�\c������w ���A#�&)`�#�jcO�r��Y����v@�`S
���*Zk��5�:5m�>B�s�^ѩ>׋�L��@@}��.d�O+/W=o�^�/N�y�u_�ERW]<\N��k�UP�z�~�5�<*�<�@@��5�pf�==v�nI+cn���b�}H�
���;|��ĚV���/��C���γf�Nۇq���͊���&/rG��Շ��{=�y�cD���^���݃���J�z��t�< �  *a_�K�m�������[;��17h�N�p'x	BNn�=�:\?�>d��0�C�*��|�yĶ=~���l��J�+U��.F��@]�@kk���ż��B�-t�����{�_��rУ;�X����)�*��AN���E��M$�
k�>F�u�U���P��ܳ ��3%-�pr�j	M$ �h�����Ӱ�T�FU8e��W�(w�h�+%�:���</"#�O�:^�*��z%)�[�*x19�*��3|��_R����3/!�Pa}�Wi��ߢWjX�������(�0�>Y����W���s���v�NGb:y��{�C�zp�-Q`�@�d���y���U�����U�+7���32ɥx�o1��/Kغ����S�_�h�ї�¦�w�Э�X��s��m��*�8q��||��;�rE����v%�҉6)��hJ��0;DA�^�����Ώ[�>͵F�c�U��t�pk�c�/��bl�v�D\�,���`���r�gx%��CL�+s%纾6�U��_D6��k�Q��ppa��VG�Ցf�$}	s�%	��R���}��(������ҤL���m���l���gNu����œ6Ti�K�~׳Kj�Ŕ<'l�*�b�U��;�x$��� st�%��m�W�lV*L�ye$]=�թL�n9: ��oޒ�:� `.�+#E՝�_��F���*�9{��¾��D���2ݪ� t%�9۰�m��N��"��^*���/�SѪpC�R����1�_Ξ�����z����yz�K"6	)��w};�W�Ny��B	�B9���BaG���x����O�r���Jx"�=���D(�Q(�P��P�ӠD��P���`�������^�D񍎋�w��F���;Q����(��q	�N��{'�pt\���8:.�މR��$�0��n�#؝3��}@p0�9�C��O,2;��ȀlC��c�vL�5��r����x�5��g�޲��Ǣ�?d�v�~Y���%�#�P<����F���L��ݚf�RA{X2�	e�g^{�נ��#�[Ґ�{I�J�'ٷ�ۣX���~�����Cc�Y��!8"?9tNN`I����õU^�8i��J�����pGA���]���I���o�F;p���ϻ�x_�L��PkҜ��� $��������E�H)m�-aQ�����rr�<�7���~Fo�|���ܺ�ڞ�P���Ƴ��%E�/�El���h����'���C���v�O&���dc{b@���_!mO��1{n����ڃR��μ�ۛf��q1f!������dخ{�O�[�b"�f5���T7F,!���U�4y]}�!�FJ������C��	������ '/ /�'Cg�C��Y�`�,���-�
=�8���Ʒ�cWJ�����׸/&��TU�Iޞ�F�l~��@�Id�JsF�=p��=���᳡_Ɠ��q��[M�)c8��&�>G�|�_A�6n�q��a@u�a� �܎��g�b�xy�<��!�Z��]}u��6�z�9v"#{[�c�!Թ�v�30lّ#�l���Y񟚕��Y�@��9��S��?5+�S�X��D���ړa4Rs �k�܎��4L�$d<bηA�b�}d��qr�a�� AT�m�����"��g�̍��_%����ln�
��:L� ������E�������k�j�OK�A`��#d����Ͽ�����      �      x����n�:ǯӧ��}1��'!_\Ph�
�e�΍�����!N�r4�y�s7���M�If9�t�ufT		��x�����p�&uX�Q)*�'w���]D�7����oC��so��Mv�j�����)�B��f�����_u�;�v��Jj��H�c�5�Ր!#�,^C�t��ǿ�<�q���>	C"�<c2OX���.C4bI�S9�$f�O刉�TNqJe�g�����!�QCvM�dUk�p��hH��8�|��4CVզn7��8�#�}C�p�+��>��q2�/J �~��ٳV��;���Fc�4;c�el�������ol�ǁ��`��P���g�ʃO�OH��}�G$����1����w�X��;�3�9��r<��q��vi�h��t��*�B�9���I=��C%�6��ʩ
��������\g�=<^���c��Gg�?�6������q��#�A��E 4jȪ��"{�!2�e�0��K0��`�LC9%<�9�'r���}�}��%͙�Z�O�z)�=�=��ҘJ��	%*&*�m_:����C'��>�������d|�r;k���$���z�-���v7t$�^S�3to�k,���ea�@@���$��a��ޕG!'�.cץAHq�����'�R���bƚ�VAO��,%�)K��9[���ʾ7��qZ�~���ݠN����)2����v7�#����I�}x*r���4������މ�R6,e!
>a�9{�7�yk�dኂ�%��ȉ4C�W�p���痠Y�*�5��2ci� �#%�
hYw�X�c��.��p�G��?�y���>%�N�<noz�i��g\��{5�M!6���j��AqX	�߿���S�<&��1�*'Q�P�Ģ8g;*g�2q��J
���׀9U�	*��S�I]�V�fLJO3
9�T��f�H���q�P{i7�Q�"���C}p;;\u���G����5��֜&�P[������ s*�'���1`D.L�A�
�ω� JE̸zŧ��IJ��h.W|�X�e�v���)͠�Km
!���a��堂��݉Rbl�}�$��� �΁����;�ۺ��^v��?R�q1x,�M/BUϨ���֠x��x:��dPF��B�1�`�!0KIao��">��_��@
mIbYB��/Ҳ�����Κ
bw�0P�%�*Q9�`�7��A�y��,��\�7[�|>9l[lyP�dŵֶ�9��D��-�k���5�4�Yy���d�.�B����fB�hD�[)��%>-���A�"L��h�XO��j�T]z��W��RN�v�%8�T�ݎ�v��Y��o�|>K$S���{4���>��懛Ƭ{���d��� ��n΄��',��A0X�0մ�ﲍ���HJ���|��5ˠA��:�ެ������k�E��^���m.������9���y��w�2��n$���uh��8���m�z�?��JE⮐�D�b�����7i5�Z1��Q�w)�MHPU�?�&,d�x�[��U���w\����>to��Ժ�W�-�C���di޵�(94��䞘���Ux�]����e��I}�Sp��L��_/{�����y��Q���f��0M�VԆ�J�j4xj(f�0�Th����p.l�5ŅJD|VDe��CDn{٭�Y~����-J�[�M��^�t_L6��^�8�FKm�e�cz��Њc�{&|*�~Y��P�P��3�_Tp����GL�m�v!�Ma/秖*���Y��7����'"��2j���"�!�A߂�� �o��Ͻ�E����F���     