import pandas as pd
import heapq
import subprocess

data_path = 'dataset_property_east_java.csv'
df = pd.read_csv(data_path)

df['Kelas_Fasilitas_Sekitar'] = df['Kelas_Fasilitas_Sekitar'].apply(lambda x: [fasilitas.strip() for fasilitas in x.split(';')] if pd.notna(x) else [])

def calculate_g(properti):
    harga_jual = properti['Harga_Jual_Properti']
    harga_beli = properti['Harga_Beli_Properti']
    return harga_jual - harga_beli 

def calculate_h(properti, lama_investasi):
    kenaikan_harga = properti['Kenaikan_Harga'] / 100
    harga_beli = properti['Harga_Beli_Properti']
    harga_prediksi = harga_beli * ((1 + kenaikan_harga) ** lama_investasi)
    biaya_operasional = properti['Biaya_Operasional_Tahunan'] * lama_investasi
    return harga_prediksi - harga_beli - biaya_operasional

def a_star_search(df, modal, city, lama_investasi):
    filtered_df = df[(df['Harga_Beli_Properti'] <= modal) & (df['Kota'] == city)]
    if filtered_df.empty:
        return "Tidak ada properti yang memenuhi kriteria."
    
    queue = []
    heapq.heapify(queue)

    best_investment = None
    for index, properti in filtered_df.iterrows():
        g_n = calculate_g(properti)
        h_n = calculate_h(properti, lama_investasi)
        f_n = g_n + h_n  
        heapq.heappush(queue, (-f_n, (properti, g_n, h_n, f_n)))

    best_investment = heapq.heappop(queue)[1]
    return best_investment

def run_reasoning_in_prolog(properti):
    fasilitas_str = ', '.join([f"'{fasilitas}'" for fasilitas in properti['Kelas_Fasilitas_Sekitar']])
    
    properti_fakta = f"properti('{properti['ID_Properti']}', '{properti['Tipe_Properti']}', " \
                     f"{properti['Harga_Beli_Properti']}, {properti['Biaya_Operasional_Tahunan']}, " \
                     f"{properti['Kenaikan_Harga']}, [{fasilitas_str}], {properti['Usia_Properti']})."

    with open("reasoning_prolog.pl", "a") as file:
        file.write("\n"+properti_fakta)

    try:
        result = subprocess.run(
            ["swipl", "-s", "reasoning_prolog.pl", "-g", 
             f"run_reasoning('{properti['ID_Properti']}', Wilayah, Market, Strategi, Risiko), halt."],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        
        if result.stderr:
            print("Error dari Prolog:", result.stderr)
            return result.stderr
        
        with open("output.txt", "w") as outfile:
            outfile.write(result.stdout)

        return result.stdout
    except Exception as e:
        return f"Error menjalankan Prolog: {e}"

def main():
    modal = float(input("Masukkan modal yang tersedia: "))
    city = input("Masukkan kota: ")
    lama_investasi = int(input("Masukkan lama investasi dalam tahun: "))
    result = a_star_search(df, modal, city, lama_investasi)
    
    if isinstance(result, str):
        print(result)
    else:
        properti, g_n, h_n, f_n = result
        
        print("\nProperti terbaik untuk investasi berdasarkan kriteria Anda:")
        print(properti)
        print(f"g(n) = {g_n}, h(n) = {h_n}, f(n) = {f_n}")
        
        reasoning_output = run_reasoning_in_prolog(properti) 
        print("\nTarget Invest dan Informasi:")
        print(reasoning_output)

if __name__ == "__main__":
    main()
