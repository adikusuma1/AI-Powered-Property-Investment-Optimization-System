tujuan(Properti, hunian) :-
    properti(Properti, Type, _, _, _, _, _),
    member(Type,['Rumah Tunggal','Vila','Komplek Perumahan','Apartemen']).

tujuan(Properti, bisnis) :-
    properti(Properti, Type, _, _, _, _, _),
    member(Type,['Ruko','Gedung','Gudang']).

market(Properti, mahasiswa):-
    tujuan(Properti, hunian),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member('Universitas', FasilitasList).

market(Properti, pekerja_kantoran):-
    tujuan(Properti, hunian),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member('Kantor', FasilitasList).

market(Properti, family_house) :-
    tujuan(Properti, hunian),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member(Fasilitas, FasilitasList),
    member(Fasilitas, ['Pusat Perbelanjaan', 'Sekolah', 'Taman']).

market(Properti, pariwisata):-
    tujuan(Properti, hunian),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member(Fasilitas, FasilitasList),
    member(Fasilitas, ['Objek Wisata', 'Pusat Hiburan']).

market(Properti, umkm):-
    tujuan(Properti, bisnis),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member('Pusat Perbelanjaan', FasilitasList).

market(Properti, office):-
    tujuan(Properti, bisnis),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member('Kantor', FasilitasList).

market(Properti, industrial):-
    tujuan(Properti, bisnis),
    properti(Properti, _, _, _, _, FasilitasList, _),
    member('Pabrik', FasilitasList).

jenis_wilayah(Properti, urban) :-
    properti(Properti, _, _, _, _, TypeList, _),
    member(Type, TypeList),
    member(Type, ['Pusat Perbelanjaan', 'Kantor', 'Transportasi Umum', 'Pusat Hiburan']).

jenis_wilayah(Properti, suburban) :-
    properti(Properti, _, _, _, _, TypeList, _),
    member(Type, TypeList),
    member(Type, ['Pabrik','Objek Wisata']).

strategi_investasi(Properti, flipping) :-
    properti(Properti, _, Harga_Beli_Properti, Biaya_Operasional, Kenaikan,_ , _),
    Biaya_Operasional < Kenaikan/100 * Harga_Beli_Properti,
    jenis_wilayah(Properti, suburban).

strategi_investasi(Properti, invest_jangka_panjang) :-
    properti(Properti, _, Harga_Beli_Properti, Biaya_Operasional, Kenaikan,_ , _),
    Biaya_Operasional >= Kenaikan/100 * Harga_Beli_Properti,
    jenis_wilayah(Properti, urban).
    
estimasi_risiko(Properti, tinggi) :-
    properti(Properti, _, _, _, _, _,Usia_Properti),
    Usia_Properti > 40.

estimasi_risiko(Properti, sedang) :-
    properti(Properti, _, _, _, _, _,Usia_Properti),
    Usia_Properti >= 20,
    Usia_Properti =< 40.

estimasi_risiko(Properti, rendah) :-
    properti(Properti, _, _, _, _, _,Usia_Properti),
    Usia_Properti < 20.

run_reasoning(Properti, Wilayah, Market, Strategi, Risiko) :-
    findall(Market, market(Properti, Market), Markets),
    sort(Markets, MarketList),
    write('Target Market\t: '), write(MarketList), nl,
    jenis_wilayah(Properti, Wilayah),
    write('Wilayah\t\t: '), write(Wilayah), nl,
    strategi_investasi(Properti, Strategi),
    write('Strategi\t: '), write(Strategi), nl,
    estimasi_risiko(Properti, Risiko),
    write('Risiko\t\t: '), write(Risiko), nl.

:- dynamic(properti/7).

properti('PID3385', 'Komplek Perumahan', 892645307, 24118828.323882047, 3, ['Pabrik, Taman'], 46).