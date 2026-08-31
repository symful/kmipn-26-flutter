/// Static string constants for the SIGAP application.
/// Use these constants instead of hardcoded strings throughout the app.
abstract class Strings {
  // General
  static const String appTitle = 'SIGAP';
  static const String batal = 'Batal';
  static const String simpan = 'Simpan';
  static const String kirim = 'Kirim';
  static const String tolak = 'Tolak';
  static const String alasanPenolakan = 'Alasan Penolakan';
  static const String selesai = 'Selesai';
  static const String submitted = 'Submitted';
  static const String rejected = 'Rejected';
  static const String lihatSemua = 'Lihat semua';
  static const String cobaLagi = 'Coba Lagi';
  static const String gagal = 'Gagal';
  static const String tutup = 'Tutup';
  static const String lihatDiPeta = 'Lihat di Peta';
  static const String detail = 'Detail';
  static const String hapusSemua = 'Hapus Semua';
  static const String kirimBukti = 'Kirim Bukti';

  // Navigation
  static const String beranda = 'Beranda';
  static const String tugas = 'Tugas';
  static const String buat = 'Buat';
  static const String notifikasi = 'Notifikasi';
  static const String profil = 'Profil';
  static const String laporan = 'Laporan';
  static const String peta = 'Peta';
  static const String akun = 'Akun';

  // Action labels
  static const String terima = 'Terima';
  static const String menunggu = 'Menunggu';
  static const String proses = 'Proses';
  static const String diterima = 'Diterima';

  // Status labels
  static const String perluTindakan = 'Perlu tindakan';
  static const String diproses = 'Diproses';
  static const String status = 'Status';
  static const String kategori = 'Kategori';
  static const String nama = 'Nama';
  static const String deskripsi = 'Deskripsi';
  static const String lokasi = 'Lokasi';
  static const String tanggal = 'Tanggal';
  static const String jumlah = 'Jumlah';
  static const String prioritas = 'Prioritas';

  // Dashboard titles
  static const String dashboardOperator = 'Dashboard Operator';
  static const String dashboardPengambilKeputusan =
      'Dashboard Pengambil Keputusan';
  static const String daftarKasus = 'Daftar Kasus';

  // Detail titles
  static const String detailKasus = 'Detail Kasus';
  static const String detailKasusOperator = 'Detail Kasus Operator';
  static const String detailKasusVerifikasi = 'Detail Kasus Verifikasi';
  static const String detailLaporan = 'Detail Laporan';
  static const String detailTugas = 'Detail Tugas';

  // Warga screens
  static const String laporanSaya = 'Laporan saya';
  static const String belumAdaAktivitas = 'Belum ada aktivitas';
  static const String kirimBuktiTambahan = 'Kirim Bukti Tambahan';
  static const String belumAdaFoto = 'Belum ada foto';

  // Verifikator
  static const String survei = 'Survei';
  static const String kirimSurveyor = 'Kirim surveyor';
  static const String tolakLaporan = 'Tolak laporan';
  static const String kirimKeputusan = 'Kirim Keputusan';
  static const String masukkanIdLaporanDuplikat =
      'Masukkan ID laporan duplikat';
  static const String masukkanIdSurveyor = 'Masukkan ID surveyor';

  // Exec
  static const String petugasAktif = 'Petugas Aktif';

  // Admin
  static const String namaWilayahWAJIB = 'Nama Wilayah (WAJIB)';
  static const String namaUnitWAJIB = 'Nama Unit (WAJIB)';
  static const String namaWAJIB = 'Nama (WAJIB)';
  static const String simpanKonfigurasi = 'Simpan Konfigurasi';

  // Dialogs
  static const String tolakTugas = 'Tolak Tugas';
  static const String masukkanAlasanPenolakan = 'Masukkan alasan penolakan...';
  static const String masukkanPertanyaanAnda = 'Masukkan pertanyaan Anda...';
  static const String alasanPemisahan =
      'Masukkan alasan mengapa kasus ini perlu dipisahkan';
  static const String idUnitTugas = 'Masukkan ID unit tugas';
  static const String alasanMerge = 'Masukkan ID kasus untuk merge';

  // Messages
  static const String laporanTersimpan =
      'Laporan tersimpan. Akan sinkron otomatis.';
  static const String surveiBerhasilDikirim = 'Survei berhasil dikirim!';
  static const String simpanDanSinkronkanNanti = 'Simpan dan sinkronkan nanti';
  static const String submitFailed = 'Submit failed';
  static const String kirimLaporan = 'Kirim Laporan';
  static const String simpanProgress = 'Simpan Progress';
  static const String kirimVerifikasi = 'Kirim Verifikasi';
  static const String mengirirmuatan = 'Mengirim...';

  // RW/RT
  static const String rw = 'RW';
  static const String rwMinus = 'RW -';

  // Surveyor
  static const String prioritasSlider = 'Prioritas';
  static const String kirimHasilKunjungan = 'Kirim Hasil Kunjungan';
  static const String hariIni = 'Hari ini';
  static const String terlambat = 'Terlambat';
  static const String belumDiunduh = 'Belum diunduh';
  static const String sinkron = 'Sinkron';
  static const String riwayat = 'Riwayat';

  // Widget labels
  static const String kasusTerdekat = 'Kasus terdekat';
  static const String lihatPeta = 'Lihat peta';
  static const String lihatArrow = 'Lihat \u2192';
  static const String hapusUnduhanOffline = 'Hapus unduhan offline';
  static const String detailPerubahan = 'Detail: {action}';
  static const String lihatDetailPerubahan = 'Lihat detail perubahan';
  static const String laporanIdDuplikat = 'Laporan: {reportId}';
  static const String idLaporanDuplikat = 'Masukkan ID laporan yang duplikat';
  static const String keluar = 'Keluar';
  static const String detailLaporanVerifikasi = 'Detail Laporan Verifikasi';
  static const String laporanDuplicate = 'Laporan duplicate';

  // Status mappings
  static const String perluTindakanCapital = 'Perlu Tindakan';
  static const String ditolak = 'Ditolak';
  static const String duplikat = 'Duplikat';
  static const String perluSurvei = 'Perlu Survei';
  static const String unknown = 'Unknown';

  // Additional labels
  static const String mergeDuplikat = 'Merge duplikat';
  static const String tandaiDuplikat = 'Tandai Duplikat';
  static const String diluteJangkauan = 'Diluar Jangkauan';
  static const String dilute = 'Diluar';
  static const String perluKelengkapan = 'Perlu kelengkapan';
  static const String perluDilengkapi = 'Perlu dilengkapi';
  static const String perluLengkapi = perluDilengkapi;
  static const String underReview = 'Under Review';
  static const String verified = 'Verified';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String konfirmasi = 'Konfirmasi';
  static const String filter = 'Filter';
  static const String reset = 'Reset';
  static const String tersimpan = 'Tersimpan';
  static const String tersimpanDiPerangkat = 'Tersimpan di perangkat';
  static const String perluTindakanAnda = 'Perlu tindakan Anda';
  static const String idLaporanDuplikatHint =
      'Masukkan ID laporan yang duplikat';
  static const String mengirim = 'Mengirim...';

  // Additional hardcoded strings found in features
  static const String tanpaJudul = 'Tanpa judul';
  static const String baruSaja = 'Baru saja';
  static const String tidakAdaTugas = 'Tidak ada tugas';
  static const String tugasSurveiAkanMuncul =
      'Tugas survei akan muncul di sini';
  static const String gagalMemuatTugas = 'Gagal memuat tugas';
  static const String belumAdaRiwayat = 'Belum ada riwayat';
  static const String visitYangDikirimAkanMuncul =
      'Visit yang dikirim akan muncul di sini';
  static const String gagalMemuatRiwayat = 'Gagal memuat riwayat';
  static const String terbaru = 'Terbaru';
  static const String slaTerdekat = 'SLA terdekat';
  static const String sinkronkan = 'Sinkronkan';
  static const String kemarin = 'Kemarin';
  static const String hariYangLalu = 'hari yang lalu';
  static const String mingguYangLalu = 'minggu yang lalu';
  static const String jamYangLalu = 'jam yang lalu';
  static const String menitYangLalu = 'menit yang lalu';
  static const String filterAntrean = 'Filter Antrean';
  static const String terapkan = 'Terapkan';
  static const String sortir = 'Sortir';
  static const String filterStatus = 'Filter Status';
  static const String prioritasTertinggi = 'Prioritas Tertinggi';
  static const String semua = 'Semua';
  static const String dalamProses = 'Dalam Proses';
  static const String diverifikasi = 'Diverifikasi';
  static const String laporanDiterima = 'Laporan diterima';
  static const String laporanTidakJelas = 'Laporan tidak jelas';
  static const String refresh = 'Refresh';
  static const String tidakAdaKasus = 'Tidak Ada Kasus';
  static const String tidakAdaKasusDenganFilter =
      'Tidak ada kasus dengan filter';
  static const String belumAdaKasusMasuk = 'Belum ada kasus yang masuk.';
  static const String resetFilter = 'Reset Filter';
  static const String tidakAdaLaporanDiAntrean = 'Tidak Ada Laporan di Antrean';
  static const String tidakAdaLaporanSesuaiFilter =
      'Tidak ada laporan yang sesuai dengan filter yang aktif.';
  static const String semuaLaporanSelesaiDiverifikasi =
      'Semua laporan masuk telah selesai diverifikasi.';
  static const String hapusFilter = 'Hapus Filter';
  static const String verifikatorAntrian = 'Verifikator - Antrian';
  static const String labelWilayahAktif = 'Wilayah aktif';
  static const String buatLaporan = 'Buat laporan';
  static const String fotoLokasiKondisi = 'Foto, lokasi, dan kondisi lapangan';
  static const String laporanYangAndaKirimkan =
      'Laporan yang Anda kirimkan akan dicatat di sini.';
  static const String tanpaDeskripsi = '-';
  static const String exportPdf = 'Ekspor PDF';
  static const String pdfSaved = 'PDF saved';
  static const String error = 'Error';
  static const String terkirim = 'Terkirim';
  static const String verifikasi = 'Verifikasi';
  static const String kembali = 'Kembali';
  static const String foto = 'Foto';
  static const String timeline = 'Timeline';
  static const String tindakan = 'Tindakan';
  static const String valid = 'Valid';
  static const String rendah = 'Rendah';
  static const String tinggi = 'Tinggi';
  static const String merge = 'Merge';
  static const String eskalasi = 'Eskalasi';
  static const String baru = 'Baru';
  static const String ditugaskan = 'Ditugaskan';
  static const String mengerjakan = 'Dikerjakan';
  static const String unduh = 'Unduh';
  static const String instruksi = 'Instruksi';
  static const String progress = 'Progress';
  static const String clarification = 'Clarification';
  static const String diselesaikan = 'Diselesaikan';
  static const String item = 'Item';
  static const String klarifikasi = 'Clarifikasi';
  static const String kunjungi = 'Kunjungi';
  static const String akurasiBaik = 'Akurasi baik';
  static const String berat = 'Berat';
  static const String siapOffline = 'Siap offline';
  static const String semuaTersinkron = 'Semua tersinkron';
  static const String gagalDikirim = 'Gagal dikirim';
  static const String sedangDiperiksa = 'Sedang diperiksa';
  static const String lengkapiLaporan = 'Lengkapi laporan';
  static const String reviewLaporan = 'Review laporan';
  static const String unduhBatch = 'Unduh batch';
  static const String beralihPeran = 'Ganti Peran';
  static const String sinkronLabel = 'Sinkron';
  static const String pengaturan = 'Pengaturan';
  static const String english = 'English';
  static const String tinggal = 'Tinggal';
  static const String kasusDilaporkan = 'kasus dilaporkan';
  static const String recentActivity = 'Baru saja';
}
