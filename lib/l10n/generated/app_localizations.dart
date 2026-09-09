import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'SIGAP'**
  String get appTitle;

  /// No description provided for @batal.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get batal;

  /// No description provided for @simpan.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get simpan;

  /// No description provided for @kirim.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get kirim;

  /// No description provided for @tolak.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get tolak;

  /// No description provided for @alasanPenolakan.
  ///
  /// In id, this message translates to:
  /// **'Alasan Penolakan'**
  String get alasanPenolakan;

  /// No description provided for @selesai.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get selesai;

  /// No description provided for @submitted.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi'**
  String get submitted;

  /// No description provided for @rejected.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get rejected;

  /// No description provided for @lihatSemua.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get lihatSemua;

  /// No description provided for @cobaLagi.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get cobaLagi;

  /// No description provided for @gagal.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get gagal;

  /// No description provided for @tutup.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get tutup;

  /// No description provided for @lihatDiPeta.
  ///
  /// In id, this message translates to:
  /// **'Lihat di Peta'**
  String get lihatDiPeta;

  /// No description provided for @detail.
  ///
  /// In id, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @hapusSemua.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get hapusSemua;

  /// No description provided for @kirimBukti.
  ///
  /// In id, this message translates to:
  /// **'Kirim Bukti'**
  String get kirimBukti;

  /// No description provided for @beranda.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get beranda;

  /// No description provided for @tugas.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get tugas;

  /// No description provided for @buat.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get buat;

  /// No description provided for @notifikasi.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifikasi;

  /// No description provided for @profil.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profil;

  /// No description provided for @laporan.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get laporan;

  /// No description provided for @peta.
  ///
  /// In id, this message translates to:
  /// **'Peta'**
  String get peta;

  /// No description provided for @akun.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get akun;

  /// No description provided for @terima.
  ///
  /// In id, this message translates to:
  /// **'Terima'**
  String get terima;

  /// No description provided for @menunggu.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get menunggu;

  /// No description provided for @proses.
  ///
  /// In id, this message translates to:
  /// **'Proses'**
  String get proses;

  /// No description provided for @diterima.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get diterima;

  /// No description provided for @perluTindakan.
  ///
  /// In id, this message translates to:
  /// **'Perlu tindakan'**
  String get perluTindakan;

  /// No description provided for @diproses.
  ///
  /// In id, this message translates to:
  /// **'Diproses'**
  String get diproses;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @kategori.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get kategori;

  /// No description provided for @nama.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get nama;

  /// No description provided for @deskripsi.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get deskripsi;

  /// No description provided for @lokasi.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get lokasi;

  /// No description provided for @tanggal.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get tanggal;

  /// No description provided for @jumlah.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get jumlah;

  /// No description provided for @prioritas.
  ///
  /// In id, this message translates to:
  /// **'Prioritas'**
  String get prioritas;

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @daftarKasus.
  ///
  /// In id, this message translates to:
  /// **'Daftar Kasus'**
  String get daftarKasus;

  /// No description provided for @detailKasus.
  ///
  /// In id, this message translates to:
  /// **'Detail Kasus'**
  String get detailKasus;

  /// No description provided for @detailKasusVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Detail Kasus Verifikasi'**
  String get detailKasusVerifikasi;

  /// No description provided for @detailLaporan.
  ///
  /// In id, this message translates to:
  /// **'Detail Laporan'**
  String get detailLaporan;

  /// No description provided for @detailTugas.
  ///
  /// In id, this message translates to:
  /// **'Detail Tugas'**
  String get detailTugas;

  /// No description provided for @laporanSaya.
  ///
  /// In id, this message translates to:
  /// **'Laporan saya'**
  String get laporanSaya;

  /// No description provided for @belumAdaAktivitas.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas'**
  String get belumAdaAktivitas;

  /// No description provided for @kirimBuktiTambahan.
  ///
  /// In id, this message translates to:
  /// **'Kirim Bukti Tambahan'**
  String get kirimBuktiTambahan;

  /// No description provided for @belumAdaFoto.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto'**
  String get belumAdaFoto;

  /// No description provided for @survei.
  ///
  /// In id, this message translates to:
  /// **'Survei'**
  String get survei;

  /// No description provided for @kirimSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Kirim petugas'**
  String get kirimSurveyor;

  /// No description provided for @tolakLaporan.
  ///
  /// In id, this message translates to:
  /// **'Tolak laporan'**
  String get tolakLaporan;

  /// No description provided for @kirimKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Kirim Keputusan'**
  String get kirimKeputusan;

  /// No description provided for @masukkanIdLaporanDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID laporan duplikat'**
  String get masukkanIdLaporanDuplikat;

  /// No description provided for @masukkanIdSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID petugas'**
  String get masukkanIdSurveyor;

  /// No description provided for @petugasAktif.
  ///
  /// In id, this message translates to:
  /// **'Petugas Aktif'**
  String get petugasAktif;

  /// No description provided for @namaWilayahWAJIB.
  ///
  /// In id, this message translates to:
  /// **'Nama Wilayah (WAJIB)'**
  String get namaWilayahWAJIB;

  /// No description provided for @namaUnitWAJIB.
  ///
  /// In id, this message translates to:
  /// **'Nama Unit (WAJIB)'**
  String get namaUnitWAJIB;

  /// No description provided for @namaWAJIB.
  ///
  /// In id, this message translates to:
  /// **'Nama (WAJIB)'**
  String get namaWAJIB;

  /// No description provided for @simpanKonfigurasi.
  ///
  /// In id, this message translates to:
  /// **'Simpan Konfigurasi'**
  String get simpanKonfigurasi;

  /// No description provided for @tolakTugas.
  ///
  /// In id, this message translates to:
  /// **'Tolak Tugas'**
  String get tolakTugas;

  /// No description provided for @masukkanAlasanPenolakan.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alasan penolakan...'**
  String get masukkanAlasanPenolakan;

  /// No description provided for @masukkanPertanyaanAnda.
  ///
  /// In id, this message translates to:
  /// **'Masukkan pertanyaan Anda...'**
  String get masukkanPertanyaanAnda;

  /// No description provided for @alasanPemisahan.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alasan mengapa kasus ini perlu dipisahkan'**
  String get alasanPemisahan;

  /// No description provided for @idUnitTugas.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID unit tugas'**
  String get idUnitTugas;

  /// No description provided for @alasanMerge.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID kasus untuk merge'**
  String get alasanMerge;

  /// No description provided for @laporanTersimpan.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan laporan di perangkat ini. Periksa pengirimannya di pusat sinkronisasi.'**
  String get laporanTersimpan;

  /// No description provided for @surveiBerhasilDikirim.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah mengirim hasil survei.'**
  String get surveiBerhasilDikirim;

  /// No description provided for @simpanDanSinkronkanNanti.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan sinkronkan nanti'**
  String get simpanDanSinkronkanNanti;

  /// No description provided for @submitFailed.
  ///
  /// In id, this message translates to:
  /// **'Pengiriman gagal'**
  String get submitFailed;

  /// No description provided for @kirimLaporan.
  ///
  /// In id, this message translates to:
  /// **'Kirim Laporan'**
  String get kirimLaporan;

  /// No description provided for @simpanProgress.
  ///
  /// In id, this message translates to:
  /// **'Simpan progres'**
  String get simpanProgress;

  /// No description provided for @kirimVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Kirim Verifikasi'**
  String get kirimVerifikasi;

  /// No description provided for @mengirirmuatan.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get mengirirmuatan;

  /// No description provided for @rw.
  ///
  /// In id, this message translates to:
  /// **'RW'**
  String get rw;

  /// No description provided for @rwMinus.
  ///
  /// In id, this message translates to:
  /// **'RW -'**
  String get rwMinus;

  /// No description provided for @prioritasSlider.
  ///
  /// In id, this message translates to:
  /// **'Prioritas'**
  String get prioritasSlider;

  /// No description provided for @lanjutKeReviewHasil.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke review hasil'**
  String get lanjutKeReviewHasil;

  /// No description provided for @hariIni.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get hariIni;

  /// No description provided for @terlambat.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get terlambat;

  /// No description provided for @belumDiunduh.
  ///
  /// In id, this message translates to:
  /// **'Belum diunduh'**
  String get belumDiunduh;

  /// No description provided for @sinkron.
  ///
  /// In id, this message translates to:
  /// **'Sinkron'**
  String get sinkron;

  /// No description provided for @riwayat.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get riwayat;

  /// No description provided for @kasusTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Kasus terdekat'**
  String get kasusTerdekat;

  /// No description provided for @lihatPeta.
  ///
  /// In id, this message translates to:
  /// **'Lihat peta'**
  String get lihatPeta;

  /// No description provided for @lihatArrow.
  ///
  /// In id, this message translates to:
  /// **'Lihat →'**
  String get lihatArrow;

  /// No description provided for @hapusUnduhanOffline.
  ///
  /// In id, this message translates to:
  /// **'Hapus unduhan offline'**
  String get hapusUnduhanOffline;

  /// No description provided for @detailPerubahan.
  ///
  /// In id, this message translates to:
  /// **'Rincian: {action}'**
  String detailPerubahan(String action);

  /// No description provided for @lihatDetailPerubahan.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail perubahan'**
  String get lihatDetailPerubahan;

  /// No description provided for @laporanIdDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Laporan: {reportId}'**
  String laporanIdDuplikat(String reportId);

  /// No description provided for @idLaporanDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID laporan yang duplikat'**
  String get idLaporanDuplikat;

  /// No description provided for @keluar.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get keluar;

  /// No description provided for @detailLaporanVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Detail Laporan Verifikasi'**
  String get detailLaporanVerifikasi;

  /// No description provided for @laporanDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Laporan duplicate'**
  String get laporanDuplicate;

  /// No description provided for @perluTindakanCapital.
  ///
  /// In id, this message translates to:
  /// **'Perlu Tindakan'**
  String get perluTindakanCapital;

  /// No description provided for @ditolak.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get ditolak;

  /// No description provided for @duplikat.
  ///
  /// In id, this message translates to:
  /// **'Duplikat'**
  String get duplikat;

  /// No description provided for @perluSurvei.
  ///
  /// In id, this message translates to:
  /// **'Perlu Survei'**
  String get perluSurvei;

  /// No description provided for @unknown.
  ///
  /// In id, this message translates to:
  /// **'Belum ada informasi'**
  String get unknown;

  /// No description provided for @mergeDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Merge duplikat'**
  String get mergeDuplikat;

  /// No description provided for @tandaiDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Tandai Duplikat'**
  String get tandaiDuplikat;

  /// No description provided for @diluteJangkauan.
  ///
  /// In id, this message translates to:
  /// **'Di luar cakupan'**
  String get diluteJangkauan;

  /// No description provided for @dilute.
  ///
  /// In id, this message translates to:
  /// **'Di luar cakupan'**
  String get dilute;

  /// No description provided for @perluKelengkapan.
  ///
  /// In id, this message translates to:
  /// **'Perlu kelengkapan'**
  String get perluKelengkapan;

  /// No description provided for @perluDilengkapi.
  ///
  /// In id, this message translates to:
  /// **'Perlu dilengkapi'**
  String get perluDilengkapi;

  /// No description provided for @underReview.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get underReview;

  /// No description provided for @verified.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get verified;

  /// No description provided for @inProgress.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditangani'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get resolved;

  /// No description provided for @konfirmasi.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get konfirmasi;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @tersimpan.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get tersimpan;

  /// No description provided for @tersimpanDiPerangkat.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di perangkat'**
  String get tersimpanDiPerangkat;

  /// No description provided for @perluTindakanAnda.
  ///
  /// In id, this message translates to:
  /// **'Perlu tindakan Anda'**
  String get perluTindakanAnda;

  /// No description provided for @idLaporanDuplikatHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID laporan yang duplikat'**
  String get idLaporanDuplikatHint;

  /// No description provided for @mengirim.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get mengirim;

  /// No description provided for @tanpaJudul.
  ///
  /// In id, this message translates to:
  /// **'Tanpa judul'**
  String get tanpaJudul;

  /// No description provided for @baruSaja.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get baruSaja;

  /// No description provided for @tidakAdaTugas.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas'**
  String get tidakAdaTugas;

  /// No description provided for @tugasSurveiAkanMuncul.
  ///
  /// In id, this message translates to:
  /// **'Buka daftar ini setelah admin menugaskan survei kepada Anda.'**
  String get tugasSurveiAkanMuncul;

  /// No description provided for @gagalMemuatTugas.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tugas'**
  String get gagalMemuatTugas;

  /// No description provided for @belumAdaRiwayat.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get belumAdaRiwayat;

  /// No description provided for @visitYangDikirimAkanMuncul.
  ///
  /// In id, this message translates to:
  /// **'Visit yang dikirim akan muncul di sini'**
  String get visitYangDikirimAkanMuncul;

  /// No description provided for @gagalMemuatRiwayat.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat riwayat'**
  String get gagalMemuatRiwayat;

  /// No description provided for @terbaru.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get terbaru;

  /// No description provided for @slaTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu terdekat'**
  String get slaTerdekat;

  /// No description provided for @sinkronkan.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan'**
  String get sinkronkan;

  /// No description provided for @kemarin.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get kemarin;

  /// No description provided for @hariYangLalu.
  ///
  /// In id, this message translates to:
  /// **'hari yang lalu'**
  String get hariYangLalu;

  /// No description provided for @mingguYangLalu.
  ///
  /// In id, this message translates to:
  /// **'minggu yang lalu'**
  String get mingguYangLalu;

  /// No description provided for @jamYangLalu.
  ///
  /// In id, this message translates to:
  /// **'jam yang lalu'**
  String get jamYangLalu;

  /// No description provided for @menitYangLalu.
  ///
  /// In id, this message translates to:
  /// **'menit yang lalu'**
  String get menitYangLalu;

  /// No description provided for @filterAntrean.
  ///
  /// In id, this message translates to:
  /// **'Filter Antrean'**
  String get filterAntrean;

  /// No description provided for @terapkan.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get terapkan;

  /// No description provided for @sortir.
  ///
  /// In id, this message translates to:
  /// **'Sortir'**
  String get sortir;

  /// No description provided for @filterStatus.
  ///
  /// In id, this message translates to:
  /// **'Filter status'**
  String get filterStatus;

  /// No description provided for @prioritasTertinggi.
  ///
  /// In id, this message translates to:
  /// **'Prioritas Tertinggi'**
  String get prioritasTertinggi;

  /// No description provided for @semua.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get semua;

  /// No description provided for @dalamProses.
  ///
  /// In id, this message translates to:
  /// **'Dalam Proses'**
  String get dalamProses;

  /// No description provided for @diverifikasi.
  ///
  /// In id, this message translates to:
  /// **'Diverifikasi'**
  String get diverifikasi;

  /// No description provided for @laporanDiterima.
  ///
  /// In id, this message translates to:
  /// **'Laporan diterima'**
  String get laporanDiterima;

  /// No description provided for @laporanTidakJelas.
  ///
  /// In id, this message translates to:
  /// **'Laporan tidak jelas'**
  String get laporanTidakJelas;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Segarkan'**
  String get refresh;

  /// No description provided for @tidakAdaKasus.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Kasus'**
  String get tidakAdaKasus;

  /// No description provided for @tidakAdaKasusDenganFilter.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kasus dengan filter'**
  String get tidakAdaKasusDenganFilter;

  /// No description provided for @belumAdaKasusMasuk.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kasus yang masuk.'**
  String get belumAdaKasusMasuk;

  /// No description provided for @resetFilter.
  ///
  /// In id, this message translates to:
  /// **'Reset filter'**
  String get resetFilter;

  /// No description provided for @tidakAdaLaporanDiAntrean.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Laporan di Antrean'**
  String get tidakAdaLaporanDiAntrean;

  /// No description provided for @tidakAdaLaporanSesuaiFilter.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada laporan yang sesuai dengan filter yang aktif.'**
  String get tidakAdaLaporanSesuaiFilter;

  /// No description provided for @semuaLaporanSelesaiDiverifikasi.
  ///
  /// In id, this message translates to:
  /// **'Semua laporan masuk telah selesai diverifikasi.'**
  String get semuaLaporanSelesaiDiverifikasi;

  /// No description provided for @hapusFilter.
  ///
  /// In id, this message translates to:
  /// **'Hapus Filter'**
  String get hapusFilter;

  /// No description provided for @adminAntrian.
  ///
  /// In id, this message translates to:
  /// **'Admin - Antrian'**
  String get adminAntrian;

  /// No description provided for @labelWilayahAktif.
  ///
  /// In id, this message translates to:
  /// **'Wilayah aktif'**
  String get labelWilayahAktif;

  /// No description provided for @buatLaporan.
  ///
  /// In id, this message translates to:
  /// **'Buat laporan'**
  String get buatLaporan;

  /// No description provided for @fotoLokasiKondisi.
  ///
  /// In id, this message translates to:
  /// **'Foto, lokasi, dan kondisi lapangan'**
  String get fotoLokasiKondisi;

  /// No description provided for @laporanYangAndaKirimkan.
  ///
  /// In id, this message translates to:
  /// **'Laporan yang Anda kirimkan akan dicatat di sini.'**
  String get laporanYangAndaKirimkan;

  /// No description provided for @tanpaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Pelapor belum menambahkan uraian.'**
  String get tanpaDeskripsi;

  /// No description provided for @exportPdf.
  ///
  /// In id, this message translates to:
  /// **'Ekspor PDF'**
  String get exportPdf;

  /// No description provided for @pdfSaved.
  ///
  /// In id, this message translates to:
  /// **'PDF tersimpan'**
  String get pdfSaved;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan'**
  String get error;

  /// No description provided for @terkirim.
  ///
  /// In id, this message translates to:
  /// **'Terkirim'**
  String get terkirim;

  /// No description provided for @verifikasi.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get verifikasi;

  /// No description provided for @kembali.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get kembali;

  /// No description provided for @belumDisinkronkan.
  ///
  /// In id, this message translates to:
  /// **'Belum disinkronkan ke server'**
  String get belumDisinkronkan;

  /// No description provided for @foto.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get foto;

  /// No description provided for @timeline.
  ///
  /// In id, this message translates to:
  /// **'Linimasa'**
  String get timeline;

  /// No description provided for @tindakan.
  ///
  /// In id, this message translates to:
  /// **'Tindakan'**
  String get tindakan;

  /// No description provided for @valid.
  ///
  /// In id, this message translates to:
  /// **'Valid'**
  String get valid;

  /// No description provided for @rendah.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get rendah;

  /// No description provided for @tinggi.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get tinggi;

  /// No description provided for @merge.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan'**
  String get merge;

  /// No description provided for @eskalasi.
  ///
  /// In id, this message translates to:
  /// **'Eskalasi'**
  String get eskalasi;

  /// No description provided for @baru.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get baru;

  /// No description provided for @ditugaskan.
  ///
  /// In id, this message translates to:
  /// **'Ditugaskan'**
  String get ditugaskan;

  /// No description provided for @mengerjakan.
  ///
  /// In id, this message translates to:
  /// **'Dikerjakan'**
  String get mengerjakan;

  /// No description provided for @unduh.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get unduh;

  /// No description provided for @instruksi.
  ///
  /// In id, this message translates to:
  /// **'Instruksi'**
  String get instruksi;

  /// No description provided for @progress.
  ///
  /// In id, this message translates to:
  /// **'Progres'**
  String get progress;

  /// No description provided for @clarification.
  ///
  /// In id, this message translates to:
  /// **'Klarifikasi'**
  String get clarification;

  /// No description provided for @diselesaikan.
  ///
  /// In id, this message translates to:
  /// **'Diselesaikan'**
  String get diselesaikan;

  /// No description provided for @item.
  ///
  /// In id, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @klarifikasi.
  ///
  /// In id, this message translates to:
  /// **'Klarifikasi'**
  String get klarifikasi;

  /// No description provided for @kunjungi.
  ///
  /// In id, this message translates to:
  /// **'Kunjungi'**
  String get kunjungi;

  /// No description provided for @akurasiBaik.
  ///
  /// In id, this message translates to:
  /// **'Akurasi baik'**
  String get akurasiBaik;

  /// No description provided for @berat.
  ///
  /// In id, this message translates to:
  /// **'Berat'**
  String get berat;

  /// No description provided for @siapOffline.
  ///
  /// In id, this message translates to:
  /// **'Siap offline'**
  String get siapOffline;

  /// No description provided for @semuaTersinkron.
  ///
  /// In id, this message translates to:
  /// **'Semua tersinkron'**
  String get semuaTersinkron;

  /// No description provided for @gagalDikirim.
  ///
  /// In id, this message translates to:
  /// **'Gagal dikirim'**
  String get gagalDikirim;

  /// No description provided for @sedangDiperiksa.
  ///
  /// In id, this message translates to:
  /// **'Sedang diperiksa'**
  String get sedangDiperiksa;

  /// No description provided for @lengkapiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi laporan'**
  String get lengkapiLaporan;

  /// No description provided for @reviewLaporan.
  ///
  /// In id, this message translates to:
  /// **'Periksa laporan'**
  String get reviewLaporan;

  /// No description provided for @unduhBatch.
  ///
  /// In id, this message translates to:
  /// **'Unduh batch'**
  String get unduhBatch;

  /// No description provided for @beralihPeran.
  ///
  /// In id, this message translates to:
  /// **'Ganti Peran'**
  String get beralihPeran;

  /// No description provided for @sinkronLabel.
  ///
  /// In id, this message translates to:
  /// **'Sinkron'**
  String get sinkronLabel;

  /// No description provided for @pengaturan.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get pengaturan;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tinggal.
  ///
  /// In id, this message translates to:
  /// **'Tinggal'**
  String get tinggal;

  /// No description provided for @kasusDilaporkan.
  ///
  /// In id, this message translates to:
  /// **'kasus dilaporkan'**
  String get kasusDilaporkan;

  /// No description provided for @recentActivity.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get recentActivity;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan latar gelap untuk membaca aplikasi dengan pencahayaan redup.'**
  String get darkModeSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get selectLanguage;

  /// No description provided for @bahasaIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesia;

  /// No description provided for @englishUs.
  ///
  /// In id, this message translates to:
  /// **'English (US)'**
  String get englishUs;

  /// No description provided for @sedang.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get sedang;

  /// No description provided for @masuk.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get masuk;

  /// No description provided for @daftar.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get daftar;

  /// No description provided for @statistik.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statistik;

  /// No description provided for @exportData.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data'**
  String get exportData;

  /// No description provided for @aiConsole.
  ///
  /// In id, this message translates to:
  /// **'Konsol AI'**
  String get aiConsole;

  /// No description provided for @auditLog.
  ///
  /// In id, this message translates to:
  /// **'Log audit'**
  String get auditLog;

  /// No description provided for @sanggahan.
  ///
  /// In id, this message translates to:
  /// **'Sanggahan'**
  String get sanggahan;

  /// No description provided for @kamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get kamera;

  /// No description provided for @galeri.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get galeri;

  /// No description provided for @setuju.
  ///
  /// In id, this message translates to:
  /// **'Setuju'**
  String get setuju;

  /// No description provided for @mintaInfo.
  ///
  /// In id, this message translates to:
  /// **'Minta Info'**
  String get mintaInfo;

  /// No description provided for @assign.
  ///
  /// In id, this message translates to:
  /// **'Tugaskan'**
  String get assign;

  /// No description provided for @petaLaporan.
  ///
  /// In id, this message translates to:
  /// **'Peta Laporan'**
  String get petaLaporan;

  /// No description provided for @ketukPetaUntukMemilihLokasi.
  ///
  /// In id, this message translates to:
  /// **'Ketuk peta untuk memilih lokasi'**
  String get ketukPetaUntukMemilihLokasi;

  /// No description provided for @terapkanFilter.
  ///
  /// In id, this message translates to:
  /// **'Terapkan Filter'**
  String get terapkanFilter;

  /// No description provided for @segarkan.
  ///
  /// In id, this message translates to:
  /// **'Segarkan'**
  String get segarkan;

  /// No description provided for @segarkanData.
  ///
  /// In id, this message translates to:
  /// **'Segarkan Data'**
  String get segarkanData;

  /// No description provided for @heatmap.
  ///
  /// In id, this message translates to:
  /// **'Heatmap'**
  String get heatmap;

  /// No description provided for @pilihLokasi.
  ///
  /// In id, this message translates to:
  /// **'Pilih Lokasi'**
  String get pilihLokasi;

  /// No description provided for @pusatIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Pusat Indonesia'**
  String get pusatIndonesia;

  /// No description provided for @lokasiSaya.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Saya'**
  String get lokasiSaya;

  /// No description provided for @tidakAdaTugasUntukDiunduh.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas untuk diunduh'**
  String get tidakAdaTugasUntukDiunduh;

  /// No description provided for @kelolaUnit.
  ///
  /// In id, this message translates to:
  /// **'Kelola Unit'**
  String get kelolaUnit;

  /// No description provided for @tambahUnit.
  ///
  /// In id, this message translates to:
  /// **'Tambah Unit'**
  String get tambahUnit;

  /// No description provided for @tambahUnitBaru.
  ///
  /// In id, this message translates to:
  /// **'Tambah Unit Baru'**
  String get tambahUnitBaru;

  /// No description provided for @namaUnitWajibDiisi.
  ///
  /// In id, this message translates to:
  /// **'Nama unit wajib diisi'**
  String get namaUnitWajibDiisi;

  /// No description provided for @tidakAdaUnit.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Unit'**
  String get tidakAdaUnit;

  /// No description provided for @hintUnitName.
  ///
  /// In id, this message translates to:
  /// **'Misal: Dinas Bina Marga, Satpol PP'**
  String get hintUnitName;

  /// No description provided for @hintSearchUnit.
  ///
  /// In id, this message translates to:
  /// **'Cari unit...'**
  String get hintSearchUnit;

  /// No description provided for @kelolaKategori.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get kelolaKategori;

  /// No description provided for @tambahKategori.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori'**
  String get tambahKategori;

  /// No description provided for @tambahKategoriBaru.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori Baru'**
  String get tambahKategoriBaru;

  /// No description provided for @namaKategoriWajibDiisi.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori wajib diisi'**
  String get namaKategoriWajibDiisi;

  /// No description provided for @tidakAdaKategori.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Kategori'**
  String get tidakAdaKategori;

  /// No description provided for @hintKategoriName.
  ///
  /// In id, this message translates to:
  /// **'Misal: Jalan Rusak, Sampah Liar'**
  String get hintKategoriName;

  /// No description provided for @hintKategoriSlug.
  ///
  /// In id, this message translates to:
  /// **'misal: jalan-rusak'**
  String get hintKategoriSlug;

  /// No description provided for @hintKategoriIcon.
  ///
  /// In id, this message translates to:
  /// **'misal: road, trash, lightbulb'**
  String get hintKategoriIcon;

  /// No description provided for @hintSearchKategori.
  ///
  /// In id, this message translates to:
  /// **'Cari kategori berdasarkan nama atau slug...'**
  String get hintSearchKategori;

  /// No description provided for @labelSlug.
  ///
  /// In id, this message translates to:
  /// **'Slug (opsional)'**
  String get labelSlug;

  /// No description provided for @labelIcon.
  ///
  /// In id, this message translates to:
  /// **'Icon / Simbol (opsional)'**
  String get labelIcon;

  /// No description provided for @kelolaAkun.
  ///
  /// In id, this message translates to:
  /// **'Kelola Akun'**
  String get kelolaAkun;

  /// No description provided for @tambahAkun.
  ///
  /// In id, this message translates to:
  /// **'Tambah Akun'**
  String get tambahAkun;

  /// No description provided for @tambahAkunBaru.
  ///
  /// In id, this message translates to:
  /// **'Tambah Akun Baru'**
  String get tambahAkunBaru;

  /// No description provided for @emailNamaWajibDiisi.
  ///
  /// In id, this message translates to:
  /// **'Email dan nama wajib diisi'**
  String get emailNamaWajibDiisi;

  /// No description provided for @tidakAdaAkun.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Akun'**
  String get tidakAdaAkun;

  /// No description provided for @petugasLapangan.
  ///
  /// In id, this message translates to:
  /// **'PETUGAS (Lapangan)'**
  String get petugasLapangan;

  /// No description provided for @hintEmail.
  ///
  /// In id, this message translates to:
  /// **'contoh@daerah.go.id'**
  String get hintEmail;

  /// No description provided for @hintNamaLengkap.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap pengguna'**
  String get hintNamaLengkap;

  /// No description provided for @labelEmailWajib.
  ///
  /// In id, this message translates to:
  /// **'Email (Wajib)'**
  String get labelEmailWajib;

  /// No description provided for @labelPeranRole.
  ///
  /// In id, this message translates to:
  /// **'Peran / Role'**
  String get labelPeranRole;

  /// No description provided for @gagalMemuatWilayah.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Wilayah'**
  String get gagalMemuatWilayah;

  /// No description provided for @tidakAdaWilayah.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Wilayah'**
  String get tidakAdaWilayah;

  /// No description provided for @tambahPengguna.
  ///
  /// In id, this message translates to:
  /// **'Tambah Pengguna'**
  String get tambahPengguna;

  /// No description provided for @masukkanInformasi.
  ///
  /// In id, this message translates to:
  /// **'Masukkan informasi akun pengguna baru untuk sistem SIGAP.'**
  String get masukkanInformasi;

  /// No description provided for @belumAdaUnitKerjaTerdaftar.
  ///
  /// In id, this message translates to:
  /// **'Belum ada unit kerja yang terdaftar.'**
  String get belumAdaUnitKerjaTerdaftar;

  /// No description provided for @daftarkanUnit.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan Unit Pelaksana Teknis (UPT / SKPD / Dinas) yang bertanggung jawab atas penanganan laporan.'**
  String get daftarkanUnit;

  /// No description provided for @tambahUnitKerja.
  ///
  /// In id, this message translates to:
  /// **'Tambah Unit Kerja'**
  String get tambahUnitKerja;

  /// No description provided for @belumAdaKategoriLaporanTerdaftar.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori laporan yang terdaftar.'**
  String get belumAdaKategoriLaporanTerdaftar;

  /// No description provided for @buatKategori.
  ///
  /// In id, this message translates to:
  /// **'Buat kategori laporan baru untuk memudahkan klasifikasi pengaduan masyarakat.'**
  String get buatKategori;

  /// No description provided for @belumAdaAkunPenggunaTerdaftar.
  ///
  /// In id, this message translates to:
  /// **'Belum ada akun pengguna yang terdaftar.'**
  String get belumAdaAkunPenggunaTerdaftar;

  /// No description provided for @tidakAdaPenggunaDenganPeran.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengguna dengan peran'**
  String get tidakAdaPenggunaDenganPeran;

  /// No description provided for @semuaRole.
  ///
  /// In id, this message translates to:
  /// **'Semua Role'**
  String get semuaRole;

  /// No description provided for @konfigurasiSLA.
  ///
  /// In id, this message translates to:
  /// **'Konfigurasi SLA'**
  String get konfigurasiSLA;

  /// No description provided for @tidakAdaDataSLA.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Data SLA'**
  String get tidakAdaDataSLA;

  /// No description provided for @editSLA.
  ///
  /// In id, this message translates to:
  /// **'Edit SLA'**
  String get editSLA;

  /// No description provided for @labelTargetSLA.
  ///
  /// In id, this message translates to:
  /// **'Target Batas Waktu SLA (jam)'**
  String get labelTargetSLA;

  /// No description provided for @hintContohSLA.
  ///
  /// In id, this message translates to:
  /// **'Contoh: 24, 48, 72'**
  String get hintContohSLA;

  /// No description provided for @izinkanLokasiDitolak.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak'**
  String get izinkanLokasiDitolak;

  /// No description provided for @gagalCaptureGps.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat membaca lokasi perangkat. Periksa izin lokasi dan coba lagi. Rincian: {error}'**
  String gagalCaptureGps(String error);

  /// No description provided for @formSurvei.
  ///
  /// In id, this message translates to:
  /// **'Catat hasil survei'**
  String get formSurvei;

  /// No description provided for @kembaliKeDaftarTugas.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Daftar Tugas'**
  String get kembaliKeDaftarTugas;

  /// No description provided for @berhasilMengunduhTugas.
  ///
  /// In id, this message translates to:
  /// **'Berhasil mengunduh {count} tugas'**
  String berhasilMengunduhTugas(int count);

  /// No description provided for @tugasDimulaiPetugasLain.
  ///
  /// In id, this message translates to:
  /// **'Tugas ini sudah berubah atau tidak menerima tindakan tersebut. Muat ulang tugas dan periksa tahapnya sebelum mencoba lagi.'**
  String get tugasDimulaiPetugasLain;

  /// No description provided for @tugasDiprosesPetugasLain.
  ///
  /// In id, this message translates to:
  /// **'Tugas sudah diproses oleh petugas lain'**
  String get tugasDiprosesPetugasLain;

  /// No description provided for @gagalDenganError.
  ///
  /// In id, this message translates to:
  /// **'Gagal: {error}'**
  String gagalDenganError(String error);

  /// No description provided for @mintaClarifikasi.
  ///
  /// In id, this message translates to:
  /// **'Minta penjelasan'**
  String get mintaClarifikasi;

  /// No description provided for @unduhSemuaOffline.
  ///
  /// In id, this message translates to:
  /// **'Unduh semua untuk offline'**
  String get unduhSemuaOffline;

  /// No description provided for @hintMasukkanAlasan.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alasan...'**
  String get hintMasukkanAlasan;

  /// No description provided for @hintTulisPertanyaan.
  ///
  /// In id, this message translates to:
  /// **'Tulis pertanyaan Anda...'**
  String get hintTulisPertanyaan;

  /// No description provided for @labelAlasanPenolakan.
  ///
  /// In id, this message translates to:
  /// **'Alasan penolakan'**
  String get labelAlasanPenolakan;

  /// No description provided for @labelPertanyaanKlarifikasi.
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan / klarifikasi'**
  String get labelPertanyaanKlarifikasi;

  /// No description provided for @ambilUlangFoto.
  ///
  /// In id, this message translates to:
  /// **'Ambil Ulang Foto'**
  String get ambilUlangFoto;

  /// No description provided for @pilihDiPeta.
  ///
  /// In id, this message translates to:
  /// **'Pilih di Peta'**
  String get pilihDiPeta;

  /// No description provided for @gagalHapusMetadataFoto.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus metadata foto: {error}'**
  String gagalHapusMetadataFoto(String error);

  /// No description provided for @lokasiTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Tidak Tersedia'**
  String get lokasiTidakTersedia;

  /// No description provided for @ambilFotoTerlebihDahulu.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto terlebih dahulu'**
  String get ambilFotoTerlebihDahulu;

  /// No description provided for @aktifkanLokasiUntukMelapor.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan lokasi untuk melapor'**
  String get aktifkanLokasiUntukMelapor;

  /// No description provided for @pilihKategoriTerlebihDahulu.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori terlebih dahulu'**
  String get pilihKategoriTerlebihDahulu;

  /// No description provided for @gagalMenyimpan.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String gagalMenyimpan(String error);

  /// No description provided for @tapUntukMemilihKategori.
  ///
  /// In id, this message translates to:
  /// **'Tap untuk memilih kategori'**
  String get tapUntukMemilihKategori;

  /// No description provided for @minimal10Karakter.
  ///
  /// In id, this message translates to:
  /// **'Minimal 10 karakter...'**
  String get minimal10Karakter;

  /// No description provided for @labelPilihKategori.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kategori'**
  String get labelPilihKategori;

  /// No description provided for @labelJelaskanLaporan.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan laporan Anda'**
  String get labelJelaskanLaporan;

  /// No description provided for @labelPerkiraanTerdampak.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan jumlah warga terdampak'**
  String get labelPerkiraanTerdampak;

  /// No description provided for @sectionAmbilFoto.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto'**
  String get sectionAmbilFoto;

  /// No description provided for @sectionLokasi.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get sectionLokasi;

  /// No description provided for @sectionDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get sectionDeskripsi;

  /// No description provided for @sectionPerkiraanTerdampak.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan Jumlah Terdampak'**
  String get sectionPerkiraanTerdampak;

  /// No description provided for @sectionTingkatKerentanan.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Kerentanan'**
  String get sectionTingkatKerentanan;

  /// No description provided for @sectionDampak.
  ///
  /// In id, this message translates to:
  /// **'Dampak'**
  String get sectionDampak;

  /// No description provided for @csvSpreadsheet.
  ///
  /// In id, this message translates to:
  /// **'CSV (Spreadsheet)'**
  String get csvSpreadsheet;

  /// No description provided for @geoJsonGeospatial.
  ///
  /// In id, this message translates to:
  /// **'GeoJSON (Geospatial)'**
  String get geoJsonGeospatial;

  /// No description provided for @pdfLaporan.
  ///
  /// In id, this message translates to:
  /// **'PDF (Laporan)'**
  String get pdfLaporan;

  /// No description provided for @itemDikembalikanKeAntrian.
  ///
  /// In id, this message translates to:
  /// **'Item dikembalikan ke antrian'**
  String get itemDikembalikanKeAntrian;

  /// No description provided for @syncAll.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan semua'**
  String get syncAll;

  /// No description provided for @totalLaporan.
  ///
  /// In id, this message translates to:
  /// **'Total Laporan'**
  String get totalLaporan;

  /// No description provided for @totalKasus.
  ///
  /// In id, this message translates to:
  /// **'Total Kasus'**
  String get totalKasus;

  /// No description provided for @silakanTambahFotoDahulu.
  ///
  /// In id, this message translates to:
  /// **'Silakan tambahkan foto terlebih dahulu'**
  String get silakanTambahFotoDahulu;

  /// No description provided for @laporanBerhasilDilengkapi.
  ///
  /// In id, this message translates to:
  /// **'Laporan berhasil dilengkapi'**
  String get laporanBerhasilDilengkapi;

  /// No description provided for @gagalMelengkapiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Gagal melengkapi laporan: {error}'**
  String gagalMelengkapiLaporan(String error);

  /// No description provided for @sanggahanBerhasilDiajukan.
  ///
  /// In id, this message translates to:
  /// **'Sanggahan berhasil diajukan'**
  String get sanggahanBerhasilDiajukan;

  /// No description provided for @perjalananLaporanDitampilkan.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan laporan akan ditampilkan di sini.'**
  String get perjalananLaporanDitampilkan;

  /// No description provided for @labelTingkatPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Prioritas'**
  String get labelTingkatPrioritas;

  /// No description provided for @labelDibuat.
  ///
  /// In id, this message translates to:
  /// **'Dibuat'**
  String get labelDibuat;

  /// No description provided for @lengkapiLaporanLabel.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi laporan'**
  String get lengkapiLaporanLabel;

  /// No description provided for @sanggahKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Sanggah Keputusan'**
  String get sanggahKeputusan;

  /// No description provided for @kirimLabel.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get kirimLabel;

  /// No description provided for @ajukanSanggahanLabel.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Sanggahan'**
  String get ajukanSanggahanLabel;

  /// No description provided for @portalPublik.
  ///
  /// In id, this message translates to:
  /// **'Portal Publik'**
  String get portalPublik;

  /// No description provided for @belumAdaLaporan.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Laporan'**
  String get belumAdaLaporan;

  /// No description provided for @labelProgres.
  ///
  /// In id, this message translates to:
  /// **'Progres'**
  String get labelProgres;

  /// No description provided for @labelDukungan.
  ///
  /// In id, this message translates to:
  /// **'Dukungan'**
  String get labelDukungan;

  /// No description provided for @labelTerakhirDiperbarui.
  ///
  /// In id, this message translates to:
  /// **'Terakhir Diperbarui'**
  String get labelTerakhirDiperbarui;

  /// No description provided for @gantiPeranAktif.
  ///
  /// In id, this message translates to:
  /// **'Ganti Peran Aktif'**
  String get gantiPeranAktif;

  /// No description provided for @pengaturanAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Aplikasi'**
  String get pengaturanAplikasi;

  /// No description provided for @subtitlePengaturan.
  ///
  /// In id, this message translates to:
  /// **'Tema tampilan, pilihan bahasa, dan preferensi'**
  String get subtitlePengaturan;

  /// No description provided for @labelPeranAkses.
  ///
  /// In id, this message translates to:
  /// **'Peran & Akses'**
  String get labelPeranAkses;

  /// No description provided for @labelPengaturanPreferensi.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan & Preferensi'**
  String get labelPengaturanPreferensi;

  /// No description provided for @sectionTampilanTema.
  ///
  /// In id, this message translates to:
  /// **'Atur tampilan'**
  String get sectionTampilanTema;

  /// No description provided for @sectionBahasaLokalisasi.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa tampilan'**
  String get sectionBahasaLokalisasi;

  /// No description provided for @sectionInformasiAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Informasi Aplikasi'**
  String get sectionInformasiAplikasi;

  /// No description provided for @pilihSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Pilih petugas'**
  String get pilihSurveyor;

  /// No description provided for @labelIdLaporanDuplikatWajib.
  ///
  /// In id, this message translates to:
  /// **'ID Laporan Duplikat (WAJIB)'**
  String get labelIdLaporanDuplikatWajib;

  /// No description provided for @labelPilihSurveyorWajib.
  ///
  /// In id, this message translates to:
  /// **'Pilih Petugas (WAJIB)'**
  String get labelPilihSurveyorWajib;

  /// No description provided for @labelAlasanWajib.
  ///
  /// In id, this message translates to:
  /// **'Alasan (WAJIB)'**
  String get labelAlasanWajib;

  /// No description provided for @hintMasukkanIdLaporanDuplikat.
  ///
  /// In id, this message translates to:
  /// **'Masukkan ID laporan duplikat'**
  String get hintMasukkanIdLaporanDuplikat;

  /// No description provided for @hintBerikanAlasanKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Berikan alasan keputusan ini'**
  String get hintBerikanAlasanKeputusan;

  /// No description provided for @laporanBerhasilDiverifikasi.
  ///
  /// In id, this message translates to:
  /// **'Laporan berhasil diverifikasi'**
  String get laporanBerhasilDiverifikasi;

  /// No description provided for @laporanDitolak.
  ///
  /// In id, this message translates to:
  /// **'Laporan ditolak'**
  String get laporanDitolak;

  /// No description provided for @mintaInformasi.
  ///
  /// In id, this message translates to:
  /// **'Minta Informasi'**
  String get mintaInformasi;

  /// No description provided for @gagalMemuat.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat: {error}'**
  String gagalMemuat(String error);

  /// No description provided for @belumAdaKasusVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kasus yang perlu diverifikasi.'**
  String get belumAdaKasusVerifikasi;

  /// No description provided for @permintaanInformasiTerkirim.
  ///
  /// In id, this message translates to:
  /// **'Permintaan informasi berhasil dikirim'**
  String get permintaanInformasiTerkirim;

  /// No description provided for @semuaNotifikasiDibaca.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah menandai semua pemberitahuan sebagai dibaca.'**
  String get semuaNotifikasiDibaca;

  /// No description provided for @gagalMenandaiSemua.
  ///
  /// In id, this message translates to:
  /// **'Gagal menandai semua: {error}'**
  String gagalMenandaiSemua(String error);

  /// No description provided for @gagalMenandai.
  ///
  /// In id, this message translates to:
  /// **'Gagal menandai: {error}'**
  String gagalMenandai(String error);

  /// No description provided for @bacaSemua.
  ///
  /// In id, this message translates to:
  /// **'Tandai dibaca'**
  String get bacaSemua;

  /// No description provided for @buktiDitambahkanKeKasus.
  ///
  /// In id, this message translates to:
  /// **'Bukti berhasil ditambahkan ke kasus'**
  String get buktiDitambahkanKeKasus;

  /// No description provided for @gagalMenambahkanBukti.
  ///
  /// In id, this message translates to:
  /// **'Gagal menambahkan bukti: {error}'**
  String gagalMenambahkanBukti(String error);

  /// No description provided for @kategoriLaporanTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Kategori laporan tidak tersedia'**
  String get kategoriLaporanTidakTersedia;

  /// No description provided for @laporanTersimpanAutoSync.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan laporan di perangkat ini. Periksa pusat sinkronisasi untuk memastikan laporan sudah terkirim.'**
  String get laporanTersimpanAutoSync;

  /// No description provided for @gantiPeranPengguna.
  ///
  /// In id, this message translates to:
  /// **'Ganti Peran Pengguna'**
  String get gantiPeranPengguna;

  /// No description provided for @berhasilBeralihPeran.
  ///
  /// In id, this message translates to:
  /// **'Berhasil beralih ke peran {role}'**
  String berhasilBeralihPeran(String role);

  /// No description provided for @gagalBeralihPeran.
  ///
  /// In id, this message translates to:
  /// **'Gagal beralih peran. Silakan coba lagi.'**
  String get gagalBeralihPeran;

  /// No description provided for @errorDenganPesan.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan: {error}'**
  String errorDenganPesan(String error);

  /// No description provided for @mergeKasus.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan Kasus'**
  String get mergeKasus;

  /// No description provided for @gagalUbahStatus.
  ///
  /// In id, this message translates to:
  /// **'Gagal ubah status: {error}'**
  String gagalUbahStatus(String error);

  /// No description provided for @tugasDanProgres.
  ///
  /// In id, this message translates to:
  /// **'Tugas & Progres'**
  String get tugasDanProgres;

  /// No description provided for @detailAudit.
  ///
  /// In id, this message translates to:
  /// **'Detail Audit'**
  String get detailAudit;

  /// No description provided for @fotoBukti.
  ///
  /// In id, this message translates to:
  /// **'Foto Bukti'**
  String get fotoBukti;

  /// No description provided for @dokumen.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get dokumen;

  /// No description provided for @lihatDiPetaLabel.
  ///
  /// In id, this message translates to:
  /// **'Lihat di Peta'**
  String get lihatDiPetaLabel;

  /// No description provided for @labelPenilaianAI.
  ///
  /// In id, this message translates to:
  /// **'Penilaian AI'**
  String get labelPenilaianAI;

  /// No description provided for @izinDiperlukan.
  ///
  /// In id, this message translates to:
  /// **'Izin Diperlukan'**
  String get izinDiperlukan;

  /// No description provided for @bukaPengaturan.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get bukaPengaturan;

  /// No description provided for @aksesLokasi.
  ///
  /// In id, this message translates to:
  /// **'Akses Lokasi'**
  String get aksesLokasi;

  /// No description provided for @aksesKamera.
  ///
  /// In id, this message translates to:
  /// **'Akses Kamera'**
  String get aksesKamera;

  /// No description provided for @konfigurasiBobotTersimpan.
  ///
  /// In id, this message translates to:
  /// **'Konfigurasi bobot prioritas berhasil disimpan'**
  String get konfigurasiBobotTersimpan;

  /// No description provided for @bobotPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Bobot Prioritas'**
  String get bobotPrioritas;

  /// No description provided for @konfigurasiPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Konfigurasi Prioritas'**
  String get konfigurasiPrioritas;

  /// No description provided for @aturPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Atur Prioritas'**
  String get aturPrioritas;

  /// No description provided for @skorPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Skor Prioritas: '**
  String get skorPrioritas;

  /// No description provided for @labelAlasanPerubahan.
  ///
  /// In id, this message translates to:
  /// **'Alasan perubahan'**
  String get labelAlasanPerubahan;

  /// No description provided for @labelAlasanOpsional.
  ///
  /// In id, this message translates to:
  /// **'Alasan (opsional)'**
  String get labelAlasanOpsional;

  /// No description provided for @labelIdKasusTarget.
  ///
  /// In id, this message translates to:
  /// **'ID Kasus Target (WAJIB)'**
  String get labelIdKasusTarget;

  /// No description provided for @assignKasus.
  ///
  /// In id, this message translates to:
  /// **'Assign Kasus'**
  String get assignKasus;

  /// No description provided for @labelIdUnitWajib.
  ///
  /// In id, this message translates to:
  /// **'ID Unit (WAJIB)'**
  String get labelIdUnitWajib;

  /// No description provided for @labelInstruksiOpsional.
  ///
  /// In id, this message translates to:
  /// **'Instruksi (opsional)'**
  String get labelInstruksiOpsional;

  /// No description provided for @aiRescanBerhasil.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan ulang AI berhasil diminta'**
  String get aiRescanBerhasil;

  /// No description provided for @aiRescanGagal.
  ///
  /// In id, this message translates to:
  /// **'Gagal meminta pemeriksaan ulang: {error}'**
  String aiRescanGagal(String error);

  /// No description provided for @retryScan.
  ///
  /// In id, this message translates to:
  /// **'Periksa ulang'**
  String get retryScan;

  /// No description provided for @labelStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelConfidence.
  ///
  /// In id, this message translates to:
  /// **'Keyakinan'**
  String get labelConfidence;

  /// No description provided for @labelResult.
  ///
  /// In id, this message translates to:
  /// **'Hasil'**
  String get labelResult;

  /// No description provided for @semuaAksi.
  ///
  /// In id, this message translates to:
  /// **'Semua Aksi'**
  String get semuaAksi;

  /// No description provided for @createBuat.
  ///
  /// In id, this message translates to:
  /// **'CREATE (Buat)'**
  String get createBuat;

  /// No description provided for @updateUbah.
  ///
  /// In id, this message translates to:
  /// **'UPDATE (Ubah)'**
  String get updateUbah;

  /// No description provided for @deleteHapus.
  ///
  /// In id, this message translates to:
  /// **'DELETE (Hapus)'**
  String get deleteHapus;

  /// No description provided for @approveSetujui.
  ///
  /// In id, this message translates to:
  /// **'APPROVE (Setujui)'**
  String get approveSetujui;

  /// No description provided for @rejectTolak.
  ///
  /// In id, this message translates to:
  /// **'REJECT (Tolak)'**
  String get rejectTolak;

  /// No description provided for @semuaTipeObjek.
  ///
  /// In id, this message translates to:
  /// **'Semua Tipe Objek'**
  String get semuaTipeObjek;

  /// No description provided for @laporanReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan (Report)'**
  String get laporanReport;

  /// No description provided for @penggunaUser.
  ///
  /// In id, this message translates to:
  /// **'Pengguna (User)'**
  String get penggunaUser;

  /// No description provided for @kategoriCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori (Category)'**
  String get kategoriCategory;

  /// No description provided for @unitKerja.
  ///
  /// In id, this message translates to:
  /// **'Unit Kerja'**
  String get unitKerja;

  /// No description provided for @csvFormat.
  ///
  /// In id, this message translates to:
  /// **'Format CSV'**
  String get csvFormat;

  /// No description provided for @jsonFormat.
  ///
  /// In id, this message translates to:
  /// **'Format JSON'**
  String get jsonFormat;

  /// No description provided for @mengunduhAuditLog.
  ///
  /// In id, this message translates to:
  /// **'Mengunduh data audit log...'**
  String get mengunduhAuditLog;

  /// No description provided for @exportGagal.
  ///
  /// In id, this message translates to:
  /// **'Export gagal: {error}'**
  String exportGagal(String error);

  /// No description provided for @kondisiSebelumnya.
  ///
  /// In id, this message translates to:
  /// **'Kondisi Sebelumnya (Before)'**
  String get kondisiSebelumnya;

  /// No description provided for @kondisiSesudahnya.
  ///
  /// In id, this message translates to:
  /// **'Kondisi Sesudahnya (After)'**
  String get kondisiSesudahnya;

  /// No description provided for @metadataTambahan.
  ///
  /// In id, this message translates to:
  /// **'Metadata Tambahan'**
  String get metadataTambahan;

  /// No description provided for @labelAksi.
  ///
  /// In id, this message translates to:
  /// **'Aksi'**
  String get labelAksi;

  /// No description provided for @labelObjek.
  ///
  /// In id, this message translates to:
  /// **'Objek'**
  String get labelObjek;

  /// No description provided for @labelActor.
  ///
  /// In id, this message translates to:
  /// **'Aktor'**
  String get labelActor;

  /// No description provided for @labelTanggal.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get labelTanggal;

  /// No description provided for @exportLabel.
  ///
  /// In id, this message translates to:
  /// **'Ekspor'**
  String get exportLabel;

  /// No description provided for @supportingFactors.
  ///
  /// In id, this message translates to:
  /// **'Faktor pendukung'**
  String get supportingFactors;

  /// No description provided for @riskFactors.
  ///
  /// In id, this message translates to:
  /// **'Faktor risiko'**
  String get riskFactors;

  /// No description provided for @labelKasusBaru.
  ///
  /// In id, this message translates to:
  /// **'Kasus baru'**
  String get labelKasusBaru;

  /// No description provided for @labelPerluVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Perlu verifikasi'**
  String get labelPerluVerifikasi;

  /// No description provided for @labelSlaTerlewat.
  ///
  /// In id, this message translates to:
  /// **'Lewat batas waktu'**
  String get labelSlaTerlewat;

  /// No description provided for @labelPrioritasTinggi.
  ///
  /// In id, this message translates to:
  /// **'Prioritas tinggi'**
  String get labelPrioritasTinggi;

  /// No description provided for @labelPerluKelengkapan.
  ///
  /// In id, this message translates to:
  /// **'Perlu kelengkapan'**
  String get labelPerluKelengkapan;

  /// No description provided for @labelTotalAntrean.
  ///
  /// In id, this message translates to:
  /// **'Total Antrean'**
  String get labelTotalAntrean;

  /// No description provided for @labelTepatWaktu.
  ///
  /// In id, this message translates to:
  /// **'Tepat Waktu'**
  String get labelTepatWaktu;

  /// No description provided for @labelSedangDiproses.
  ///
  /// In id, this message translates to:
  /// **'Sedang Diproses'**
  String get labelSedangDiproses;

  /// No description provided for @labelSLATerlewatDashboard.
  ///
  /// In id, this message translates to:
  /// **'SLA Terlewat'**
  String get labelSLATerlewatDashboard;

  /// No description provided for @kasusBerisikoSLA.
  ///
  /// In id, this message translates to:
  /// **'{count} kasus berisiko SLA'**
  String kasusBerisikoSLA(int count);

  /// No description provided for @tingkatSinkronisasi.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Sinkronisasi'**
  String get tingkatSinkronisasi;

  /// No description provided for @pusatSinkronisasi.
  ///
  /// In id, this message translates to:
  /// **'Pusat Sinkronisasi'**
  String get pusatSinkronisasi;

  /// No description provided for @petugasMenunggu.
  ///
  /// In id, this message translates to:
  /// **'Petugas Menunggu'**
  String get petugasMenunggu;

  /// No description provided for @petugasLabel.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get petugasLabel;

  /// No description provided for @totalAntreanLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Antrean'**
  String get totalAntreanLabel;

  /// No description provided for @selesaiLabel.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get selesaiLabel;

  /// No description provided for @totalLaporanLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Laporan'**
  String get totalLaporanLabel;

  /// No description provided for @totalKasusLabel.
  ///
  /// In id, this message translates to:
  /// **'Total Kasus'**
  String get totalKasusLabel;

  /// No description provided for @belumAdaRiwayatVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get belumAdaRiwayatVerifikasi;

  /// No description provided for @perjalananLaporanAkanDitampilkan.
  ///
  /// In id, this message translates to:
  /// **'Perjalanan laporan akan ditampilkan di sini.'**
  String get perjalananLaporanAkanDitampilkan;

  /// No description provided for @langkahDari.
  ///
  /// In id, this message translates to:
  /// **'Langkah {current} dari {total}'**
  String langkahDari(int current, int total);

  /// No description provided for @fotoLabel.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get fotoLabel;

  /// No description provided for @deskripsiLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get deskripsiLabel;

  /// No description provided for @lokasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get lokasiLabel;

  /// No description provided for @dibuatLabel.
  ///
  /// In id, this message translates to:
  /// **'Dibuat'**
  String get dibuatLabel;

  /// No description provided for @tindakanLabel.
  ///
  /// In id, this message translates to:
  /// **'Tindakan'**
  String get tindakanLabel;

  /// No description provided for @timelineLabel.
  ///
  /// In id, this message translates to:
  /// **'Linimasa'**
  String get timelineLabel;

  /// No description provided for @photoCounter.
  ///
  /// In id, this message translates to:
  /// **'{current} / {total}'**
  String photoCounter(int current, int total);

  /// No description provided for @menungguVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Menunggu Verifikasi'**
  String get menungguVerifikasi;

  /// No description provided for @terverifikasi.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get terverifikasi;

  /// No description provided for @sedangDitangani.
  ///
  /// In id, this message translates to:
  /// **'Sedang Ditangani'**
  String get sedangDitangani;

  /// No description provided for @perluLengkapi.
  ///
  /// In id, this message translates to:
  /// **'Perlu Lengkapi'**
  String get perluLengkapi;

  /// No description provided for @surveiLabel.
  ///
  /// In id, this message translates to:
  /// **'Survei'**
  String get surveiLabel;

  /// No description provided for @tolakLabel.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get tolakLabel;

  /// No description provided for @tugaskanPetugas.
  ///
  /// In id, this message translates to:
  /// **'Tugaskan Petugas'**
  String get tugaskanPetugas;

  /// No description provided for @gabungkan.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan'**
  String get gabungkan;

  /// No description provided for @tandaiSelesai.
  ///
  /// In id, this message translates to:
  /// **'Tandai Selesai'**
  String get tandaiSelesai;

  /// No description provided for @labelSeverity.
  ///
  /// In id, this message translates to:
  /// **'Keparahan'**
  String get labelSeverity;

  /// No description provided for @labelScore.
  ///
  /// In id, this message translates to:
  /// **'Skor'**
  String get labelScore;

  /// No description provided for @petugasLabelA.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get petugasLabelA;

  /// No description provided for @clarifikasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Klarifikasi'**
  String get clarifikasiLabel;

  /// No description provided for @kunjungiLabel.
  ///
  /// In id, this message translates to:
  /// **'Kunjungi'**
  String get kunjungiLabel;

  /// No description provided for @terimaLabel.
  ///
  /// In id, this message translates to:
  /// **'Terima'**
  String get terimaLabel;

  /// No description provided for @adminDaerah.
  ///
  /// In id, this message translates to:
  /// **'Admin Daerah'**
  String get adminDaerah;

  /// No description provided for @tugasDiprosesSurveyorLain.
  ///
  /// In id, this message translates to:
  /// **'Tugas sedang diproses oleh petugas lain'**
  String get tugasDiprosesSurveyorLain;

  /// No description provided for @verifikatorMemintaInfo.
  ///
  /// In id, this message translates to:
  /// **'Verifikator meminta informasi tambahan untuk melengkapi laporan ini.'**
  String get verifikatorMemintaInfo;

  /// No description provided for @ringkasanOperasionalDaerah.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Operasional Daerah'**
  String get ringkasanOperasionalDaerah;

  /// No description provided for @dataPenangananKasusDaerah.
  ///
  /// In id, this message translates to:
  /// **'Data penanganan kasus daerah'**
  String get dataPenangananKasusDaerah;

  /// No description provided for @apaYangHarusDitanganiHariIni.
  ///
  /// In id, this message translates to:
  /// **'Apa yang harus ditangani hari ini?'**
  String get apaYangHarusDitanganiHariIni;

  /// No description provided for @petaRingkasKasus.
  ///
  /// In id, this message translates to:
  /// **'Peta ringkas kasus'**
  String get petaRingkasKasus;

  /// No description provided for @bukaPeta.
  ///
  /// In id, this message translates to:
  /// **'Buka Peta →'**
  String get bukaPeta;

  /// No description provided for @lihatSemuaKasusDiPeta.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua kasus di peta'**
  String get lihatSemuaKasusDiPeta;

  /// No description provided for @dashboardAuditor.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Auditor'**
  String get dashboardAuditor;

  /// No description provided for @auditIntegrityMonitoring.
  ///
  /// In id, this message translates to:
  /// **'Audit & pemantauan integritas'**
  String get auditIntegrityMonitoring;

  /// No description provided for @lihatLogAktivitas.
  ///
  /// In id, this message translates to:
  /// **'Lihat Log Aktivitas →'**
  String get lihatLogAktivitas;

  /// No description provided for @gagalMemuatStatistik.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat statistik'**
  String get gagalMemuatStatistik;

  /// No description provided for @gagalMemuatAntrean.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat antrean'**
  String get gagalMemuatAntrean;

  /// No description provided for @gagalMemuatTren.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat tren'**
  String get gagalMemuatTren;

  /// No description provided for @gagalMemuatKasusKritis.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kasus kritis'**
  String get gagalMemuatKasusKritis;

  /// No description provided for @gagalMemuatAnalitik.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat analitik'**
  String get gagalMemuatAnalitik;

  /// No description provided for @belumAdaKonfigurasiSLA.
  ///
  /// In id, this message translates to:
  /// **'Belum ada konfigurasi batas waktu penanganan pengaduan.'**
  String get belumAdaKonfigurasiSLA;

  /// No description provided for @tidakAdaNotifikasi.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memiliki pemberitahuan'**
  String get tidakAdaNotifikasi;

  /// No description provided for @pemberitahuanTerkait.
  ///
  /// In id, this message translates to:
  /// **'SIGAP akan menampilkan pembaruan laporan dan penugasan Anda di sini. Ketuk pemberitahuan untuk membuka laporan terkait jika tautannya tersedia.'**
  String get pemberitahuanTerkait;

  /// No description provided for @gagalMemuatNotifikasi.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat memuat pemberitahuan. Periksa koneksi dan coba lagi.'**
  String get gagalMemuatNotifikasi;

  /// No description provided for @modeGelap.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get modeGelap;

  /// No description provided for @modeGelapSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan latar gelap untuk membaca aplikasi dengan pencahayaan redup.'**
  String get modeGelapSubtitle;

  /// No description provided for @bahasaAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get bahasaAplikasi;

  /// No description provided for @pilihBahasa.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get pilihBahasa;

  /// No description provided for @peranSaatIni.
  ///
  /// In id, this message translates to:
  /// **'Peran Saat Ini'**
  String get peranSaatIni;

  /// No description provided for @akunHanyaSatuPeran.
  ///
  /// In id, this message translates to:
  /// **'Akun Anda saat ini hanya memiliki satu peran yang aktif. Hubungi Administrator Daerah jika Anda membutuhkan akses ke peran tambahan.'**
  String get akunHanyaSatuPeran;

  /// No description provided for @aktif.
  ///
  /// In id, this message translates to:
  /// **'AKTIF'**
  String get aktif;

  /// No description provided for @peranTersedia.
  ///
  /// In id, this message translates to:
  /// **'Peran Tersedia untuk Akun Ini'**
  String get peranTersedia;

  /// No description provided for @peranAktifSaatIni.
  ///
  /// In id, this message translates to:
  /// **'Peran aktif saat ini'**
  String get peranAktifSaatIni;

  /// No description provided for @tapUntukMengaktifkan.
  ///
  /// In id, this message translates to:
  /// **'Tap untuk mengaktifkan'**
  String get tapUntukMengaktifkan;

  /// No description provided for @algoritmaPenilaianPrioritas.
  ///
  /// In id, this message translates to:
  /// **'Algoritma Penilaian Prioritas'**
  String get algoritmaPenilaianPrioritas;

  /// No description provided for @aturPersentaseBobot.
  ///
  /// In id, this message translates to:
  /// **'Atur persentase bobot setiap faktor untuk menghitung skor prioritas otomatis pada setiap laporan yang masuk.'**
  String get aturPersentaseBobot;

  /// No description provided for @statusSLAAktif.
  ///
  /// In id, this message translates to:
  /// **'Status SLA Aktif'**
  String get statusSLAAktif;

  /// No description provided for @slaDinonaktifkan.
  ///
  /// In id, this message translates to:
  /// **'Jika dinonaktifkan, peringatan keterlambatan tidak dihitung'**
  String get slaDinonaktifkan;

  /// No description provided for @tentukanBatasWaktuSLA.
  ///
  /// In id, this message translates to:
  /// **'Tentukan batas waktu standar penanganan (SLA) untuk kategori laporan ini.'**
  String get tentukanBatasWaktuSLA;

  /// No description provided for @belumPunyaAkun.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get belumPunyaAkun;

  /// No description provided for @akunDemo.
  ///
  /// In id, this message translates to:
  /// **'Akun Demo'**
  String get akunDemo;

  /// No description provided for @loginGagal.
  ///
  /// In id, this message translates to:
  /// **'Login gagal'**
  String get loginGagal;

  /// No description provided for @sistemInformasiGeospasial.
  ///
  /// In id, this message translates to:
  /// **'Sistem Informasi Geospasial\n& Penanganan Laporan'**
  String get sistemInformasiGeospasial;

  /// No description provided for @gunakanAkun.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk mengirim laporan dan mengikuti perkembangannya, atau untuk membuka tugas petugas.'**
  String get gunakanAkun;

  /// No description provided for @emailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In id, this message translates to:
  /// **'email@contoh.com'**
  String get emailHint;

  /// No description provided for @emailKosong.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat email Anda.'**
  String get emailKosong;

  /// No description provided for @emailTidakValid.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali format alamat email Anda.'**
  String get emailTidakValid;

  /// No description provided for @kataSandi.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get kataSandi;

  /// No description provided for @kataSandiKosong.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi Anda.'**
  String get kataSandiKosong;

  /// No description provided for @kataSandiMinimal6.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter'**
  String get kataSandiMinimal6;

  /// No description provided for @registrasiGagal.
  ///
  /// In id, this message translates to:
  /// **'Registrasi gagal'**
  String get registrasiGagal;

  /// No description provided for @tidakDapatTerhubung.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server'**
  String get tidakDapatTerhubung;

  /// No description provided for @daftarAkun.
  ///
  /// In id, this message translates to:
  /// **'Daftar Akun'**
  String get daftarAkun;

  /// No description provided for @buatAkunBaru.
  ///
  /// In id, this message translates to:
  /// **'Buat akun warga untuk mengirim laporan dan mengikuti tindak lanjutnya.'**
  String get buatAkunBaru;

  /// No description provided for @namaLengkap.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get namaLengkap;

  /// No description provided for @namaLengkapHint.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap Anda'**
  String get namaLengkapHint;

  /// No description provided for @namaKosong.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama Anda.'**
  String get namaKosong;

  /// No description provided for @namaMinimal2.
  ///
  /// In id, this message translates to:
  /// **'Nama minimal 2 karakter'**
  String get namaMinimal2;

  /// No description provided for @kataSandiMinimal8.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 8 karakter'**
  String get kataSandiMinimal8;

  /// No description provided for @konfirmasiKataSandi.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get konfirmasiKataSandi;

  /// No description provided for @ulangiKataSandi.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi'**
  String get ulangiKataSandi;

  /// No description provided for @kataSandiTidakCocok.
  ///
  /// In id, this message translates to:
  /// **'Ketik ulang kata sandi yang sama.'**
  String get kataSandiTidakCocok;

  /// No description provided for @sudahPunyaAkun.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get sudahPunyaAkun;

  /// No description provided for @minimal8Karakter.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get minimal8Karakter;

  /// No description provided for @gagalMemuatKasusTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kasus terdekat'**
  String get gagalMemuatKasusTerdekat;

  /// No description provided for @gagalMemuatLaporan.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat laporan'**
  String get gagalMemuatLaporan;

  /// No description provided for @memuat.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get memuat;

  /// No description provided for @semuaTugasSudahDiunduh.
  ///
  /// In id, this message translates to:
  /// **'Semua tugas sudah diunduh'**
  String get semuaTugasSudahDiunduh;

  /// No description provided for @hariLalu.
  ///
  /// In id, this message translates to:
  /// **'hari lalu'**
  String get hariLalu;

  /// No description provided for @mingguLalu.
  ///
  /// In id, this message translates to:
  /// **'minggu lalu'**
  String get mingguLalu;

  /// No description provided for @jamLalu.
  ///
  /// In id, this message translates to:
  /// **'jam lalu'**
  String get jamLalu;

  /// No description provided for @jalanRusak.
  ///
  /// In id, this message translates to:
  /// **'Jalan Rusak'**
  String get jalanRusak;

  /// No description provided for @jembatan.
  ///
  /// In id, this message translates to:
  /// **'Jembatan'**
  String get jembatan;

  /// No description provided for @drainase.
  ///
  /// In id, this message translates to:
  /// **'Drainase'**
  String get drainase;

  /// No description provided for @fasilitasUmum.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas Umum'**
  String get fasilitasUmum;

  /// No description provided for @gagalMemuatPeta.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat peta'**
  String get gagalMemuatPeta;

  /// No description provided for @mendukung.
  ///
  /// In id, this message translates to:
  /// **'mendukung'**
  String get mendukung;

  /// No description provided for @tapUntukBukaKamera.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk mengambil foto bukti'**
  String get tapUntukBukaKamera;

  /// No description provided for @lokasiTerdeteksi.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Terdeteksi'**
  String get lokasiTerdeteksi;

  /// No description provided for @ambilLokasiGps.
  ///
  /// In id, this message translates to:
  /// **'Ambil Lokasi GPS'**
  String get ambilLokasiGps;

  /// No description provided for @tapUntukMendapatkanLokasi.
  ///
  /// In id, this message translates to:
  /// **'Tap untuk mendapatkan lokasi saat ini'**
  String get tapUntukMendapatkanLokasi;

  /// No description provided for @kasusSerupa.
  ///
  /// In id, this message translates to:
  /// **'{count} Kasus Serupa'**
  String kasusSerupa(int count);

  /// No description provided for @tidakDapatAksesGps.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat mengakses GPS. Pilih lokasi manual di peta.'**
  String get tidakDapatAksesGps;

  /// No description provided for @laporanTersimpanDi.
  ///
  /// In id, this message translates to:
  /// **'Laporan tersimpan di {address}'**
  String laporanTersimpanDi(String address);

  /// No description provided for @laporanTersimpanTerkirim.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menerima laporan Anda.'**
  String get laporanTersimpanTerkirim;

  /// No description provided for @laporanAnonimTersimpanDi.
  ///
  /// In id, this message translates to:
  /// **'Laporan anonim tersimpan di {address}'**
  String laporanAnonimTersimpanDi(String address);

  /// No description provided for @laporanAnonimTersimpanId.
  ///
  /// In id, this message translates to:
  /// **'Laporan anonim tersimpan: {id}'**
  String laporanAnonimTersimpanId(String id);

  /// No description provided for @tersimpanPada.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan {time}'**
  String tersimpanPada(String time);

  /// No description provided for @orang.
  ///
  /// In id, this message translates to:
  /// **'orang'**
  String get orang;

  /// No description provided for @jumlahPerkiraanTerdampak.
  ///
  /// In id, this message translates to:
  /// **'Jumlah perkiraan warga yang terdampak insiden ini'**
  String get jumlahPerkiraanTerdampak;

  /// No description provided for @seberapaRentan.
  ///
  /// In id, this message translates to:
  /// **'Seberapa rentan kelompok masyarakat setempat?'**
  String get seberapaRentan;

  /// No description provided for @pilihJenisDampak.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis dampak yang terjadi:'**
  String get pilihJenisDampak;

  /// No description provided for @keselamatan.
  ///
  /// In id, this message translates to:
  /// **'Keselamatan'**
  String get keselamatan;

  /// No description provided for @layananSekolah.
  ///
  /// In id, this message translates to:
  /// **'Layanan sekolah'**
  String get layananSekolah;

  /// No description provided for @ekonomi.
  ///
  /// In id, this message translates to:
  /// **'Ekonomi'**
  String get ekonomi;

  /// No description provided for @lingkungan.
  ///
  /// In id, this message translates to:
  /// **'Lingkungan'**
  String get lingkungan;

  /// No description provided for @bagianDariKasus.
  ///
  /// In id, this message translates to:
  /// **'Bagian dari kasus'**
  String get bagianDariKasus;

  /// No description provided for @lihatLabel.
  ///
  /// In id, this message translates to:
  /// **'Lihat'**
  String get lihatLabel;

  /// No description provided for @perjalananLaporanHeader.
  ///
  /// In id, this message translates to:
  /// **'PERJALANAN LAPORAN'**
  String get perjalananLaporanHeader;

  /// No description provided for @privasiInfo.
  ///
  /// In id, this message translates to:
  /// **'Identitas & lokasi presisi Anda hanya terlihat oleh petugas terkait. Publik melihat lokasi yang digeneralisasi.'**
  String get privasiInfo;

  /// No description provided for @gagalUrlUpload.
  ///
  /// In id, this message translates to:
  /// **'Gagal mendapatkan URL upload foto'**
  String get gagalUrlUpload;

  /// No description provided for @tambahkanFotoDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan foto yang menjelaskan kondisi laporan. Gunakan uraian untuk menunjukkan bagian yang perlu petugas periksa.'**
  String get tambahkanFotoDeskripsi;

  /// No description provided for @deskripsiOpsional.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (opsional)'**
  String get deskripsiOpsional;

  /// No description provided for @jelaskanInfoTambahan.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan informasi tambahan yang ingin Anda berikan...'**
  String get jelaskanInfoTambahan;

  /// No description provided for @alasanMinimalKarakter.
  ///
  /// In id, this message translates to:
  /// **'Alasan harus minimal {count} karakter'**
  String alasanMinimalKarakter(int count);

  /// No description provided for @gagalAjukanSanggahan.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan sanggahan: {error}'**
  String gagalAjukanSanggahan(String error);

  /// No description provided for @ajukanKeberatan.
  ///
  /// In id, this message translates to:
  /// **'Ajukan keberatan atas keputusan penolakan laporan Anda.'**
  String get ajukanKeberatan;

  /// No description provided for @alasanSanggahan.
  ///
  /// In id, this message translates to:
  /// **'Alasan Sanggahan'**
  String get alasanSanggahan;

  /// No description provided for @minimalKarakter.
  ///
  /// In id, this message translates to:
  /// **'Minimal {count} karakter'**
  String minimalKarakter(int count);

  /// No description provided for @jelaskanAlasanKeberatan.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan apa yang terlihat pada bukti tambahan ini…'**
  String get jelaskanAlasanKeberatan;

  /// No description provided for @buktiFotoOpsional.
  ///
  /// In id, this message translates to:
  /// **'Bukti Foto (opsional)'**
  String get buktiFotoOpsional;

  /// No description provided for @tambahkanFotoBukti.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan foto sebagai bukti pendukung sanggahan Anda'**
  String get tambahkanFotoBukti;

  /// No description provided for @lewatI.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get lewatI;

  /// No description provided for @izinkan.
  ///
  /// In id, this message translates to:
  /// **'Izinkan'**
  String get izinkan;

  /// No description provided for @izinDiperlukanPesan.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan untuk mengizinkan {title}, lalu kembali ke SIGAP.'**
  String izinDiperlukanPesan(String title);

  /// No description provided for @berdasarkanStatus.
  ///
  /// In id, this message translates to:
  /// **'Lihat tahap penanganan'**
  String get berdasarkanStatus;

  /// No description provided for @berdasarkanKategori.
  ///
  /// In id, this message translates to:
  /// **'Lihat jenis laporan'**
  String get berdasarkanKategori;

  /// No description provided for @aksesLokasiBody.
  ///
  /// In id, this message translates to:
  /// **'Izinkan SIGAP membaca lokasi perangkat untuk menampilkan laporan sekitar dan membantu Anda memilih titik laporan. Periksa titik sebelum mengirim.'**
  String get aksesLokasiBody;

  /// No description provided for @aksesKameraBody.
  ///
  /// In id, this message translates to:
  /// **'Izinkan kamera jika Anda ingin mengambil foto bukti melalui SIGAP. Anda juga dapat memilih foto dari perangkat.'**
  String get aksesKameraBody;

  /// No description provided for @notifikasiBody.
  ///
  /// In id, this message translates to:
  /// **'Izinkan SIGAP menampilkan pembaruan laporan dan tugas di perangkat ini. Anda dapat mengubah izin melalui pengaturan.'**
  String get notifikasiBody;

  /// No description provided for @tambahkanBukti.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan Bukti'**
  String get tambahkanBukti;

  /// No description provided for @gagalMengambilFoto.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil foto: {error}'**
  String gagalMengambilFoto(String error);

  /// No description provided for @gagalMemuatData.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data'**
  String get gagalMemuatData;

  /// No description provided for @keputusanBerhasilDikirim.
  ///
  /// In id, this message translates to:
  /// **'Keputusan berhasil dikirim'**
  String get keputusanBerhasilDikirim;

  /// No description provided for @assessmentTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Assessment tidak tersedia'**
  String get assessmentTidakTersedia;

  /// No description provided for @tidakAdaDokumen.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada dokumen'**
  String get tidakAdaDokumen;

  /// No description provided for @menungguKlaimPersonel.
  ///
  /// In id, this message translates to:
  /// **'Menunggu klaim personel'**
  String get menungguKlaimPersonel;

  /// No description provided for @informasiYangDiperlukan.
  ///
  /// In id, this message translates to:
  /// **'Informasi yang diperlukan'**
  String get informasiYangDiperlukan;

  /// No description provided for @umurBacklogKasus.
  ///
  /// In id, this message translates to:
  /// **'Umur backlog kasus'**
  String get umurBacklogKasus;

  /// No description provided for @dataTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Data tidak tersedia'**
  String get dataTidakTersedia;

  /// No description provided for @distribusiStatus.
  ///
  /// In id, this message translates to:
  /// **'Distribusi Status'**
  String get distribusiStatus;

  /// No description provided for @distribusiKategori.
  ///
  /// In id, this message translates to:
  /// **'Distribusi Kategori'**
  String get distribusiKategori;

  /// No description provided for @dataKategoriTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Data kategori tidak tersedia'**
  String get dataKategoriTidakTersedia;

  /// No description provided for @semuaPetugasAktif.
  ///
  /// In id, this message translates to:
  /// **'Semua petugas aktif'**
  String get semuaPetugasAktif;

  /// No description provided for @terjadiKesalahan.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get terjadiKesalahan;

  /// No description provided for @koneksiTimeout.
  ///
  /// In id, this message translates to:
  /// **'Koneksi timeout. Coba lagi.'**
  String get koneksiTimeout;

  /// No description provided for @tidakAdaKoneksiInternet.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet.'**
  String get tidakAdaKoneksiInternet;

  /// No description provided for @permintaanDibatalkan.
  ///
  /// In id, this message translates to:
  /// **'Permintaan dibatalkan.'**
  String get permintaanDibatalkan;

  /// No description provided for @emailAtauPasswordSalah.
  ///
  /// In id, this message translates to:
  /// **'Email atau password salah.'**
  String get emailAtauPasswordSalah;

  /// No description provided for @sesiHabis.
  ///
  /// In id, this message translates to:
  /// **'Sesi habis. Silakan login kembali.'**
  String get sesiHabis;

  /// No description provided for @andaTidakMemilikiAkses.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses.'**
  String get andaTidakMemilikiAkses;

  /// No description provided for @dataTidakDitemukan.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get dataTidakDitemukan;

  /// No description provided for @dataTidakValid.
  ///
  /// In id, this message translates to:
  /// **'Data tidak valid. Periksa input Anda.'**
  String get dataTidakValid;

  /// No description provided for @serverSedangBermasalah.
  ///
  /// In id, this message translates to:
  /// **'Server sedang bermasalah. Coba lagi nanti.'**
  String get serverSedangBermasalah;

  /// No description provided for @terlaluBanyakPermintaan.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak permintaan. Coba lagi nanti.'**
  String get terlaluBanyakPermintaan;

  /// No description provided for @dataSudahAdaAtauKonflik.
  ///
  /// In id, this message translates to:
  /// **'Data sudah ada atau konflik.'**
  String get dataSudahAdaAtauKonflik;

  /// No description provided for @serverTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Server tidak tersedia. Coba lagi nanti.'**
  String get serverTidakTersedia;

  /// No description provided for @terjadiKesalahanDenganCode.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan (code: {statusCode}).'**
  String terjadiKesalahanDenganCode(int statusCode);

  /// No description provided for @apiError.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan API: {statusCode}'**
  String apiError(int statusCode);

  /// No description provided for @requestTimeoutPada.
  ///
  /// In id, this message translates to:
  /// **'Request timeout pada {endpoint}'**
  String requestTimeoutPada(String endpoint);

  /// No description provided for @minimal10KarakterValidasi.
  ///
  /// In id, this message translates to:
  /// **'minimal 10 karakter'**
  String get minimal10KarakterValidasi;

  /// No description provided for @tidakDitemukan.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get tidakDitemukan;

  /// No description provided for @tidakBolehKosong.
  ///
  /// In id, this message translates to:
  /// **'tidak boleh kosong'**
  String get tidakBolehKosong;

  /// No description provided for @formatEmailTidakValid.
  ///
  /// In id, this message translates to:
  /// **'format email tidak valid'**
  String get formatEmailTidakValid;

  /// No description provided for @terlaluPanjang.
  ///
  /// In id, this message translates to:
  /// **'terlalu panjang'**
  String get terlaluPanjang;

  /// No description provided for @terlaluPendek.
  ///
  /// In id, this message translates to:
  /// **'terlalu pendek'**
  String get terlaluPendek;

  /// No description provided for @harus.
  ///
  /// In id, this message translates to:
  /// **'harus'**
  String get harus;

  /// No description provided for @gagalMendekodeGambar.
  ///
  /// In id, this message translates to:
  /// **'Gagal mendekode gambar untuk menghapus EXIF'**
  String get gagalMendekodeGambar;

  /// No description provided for @menungguVerifikasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi'**
  String get menungguVerifikasiLabel;

  /// No description provided for @terverifikasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get terverifikasiLabel;

  /// No description provided for @sedangDitanganiLabel.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditangani'**
  String get sedangDitanganiLabel;

  /// No description provided for @perluKelengkapanLabel.
  ///
  /// In id, this message translates to:
  /// **'Perlu kelengkapan'**
  String get perluKelengkapanLabel;

  /// No description provided for @slaTerlewatLabel.
  ///
  /// In id, this message translates to:
  /// **'SLA terlewat'**
  String get slaTerlewatLabel;

  /// No description provided for @tersimpanDiPerangkatLabel.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di perangkat'**
  String get tersimpanDiPerangkatLabel;

  /// No description provided for @laporanDiterimaLabel.
  ///
  /// In id, this message translates to:
  /// **'Laporan diterima'**
  String get laporanDiterimaLabel;

  /// No description provided for @sedangDiperiksaLabel.
  ///
  /// In id, this message translates to:
  /// **'Sedang diperiksa'**
  String get sedangDiperiksaLabel;

  /// No description provided for @perluDilengkapiLabel.
  ///
  /// In id, this message translates to:
  /// **'Perlu dilengkapi'**
  String get perluDilengkapiLabel;

  /// No description provided for @perluTindakanAndaLabel.
  ///
  /// In id, this message translates to:
  /// **'Perlu tindakan Anda'**
  String get perluTindakanAndaLabel;

  /// No description provided for @draftLabel.
  ///
  /// In id, this message translates to:
  /// **'Draf'**
  String get draftLabel;

  /// No description provided for @digabungLabel.
  ///
  /// In id, this message translates to:
  /// **'Digabung'**
  String get digabungLabel;

  /// No description provided for @dipisahLabel.
  ///
  /// In id, this message translates to:
  /// **'Dipisah'**
  String get dipisahLabel;

  /// No description provided for @dalamReviewLabel.
  ///
  /// In id, this message translates to:
  /// **'Dalam Review'**
  String get dalamReviewLabel;

  /// No description provided for @unknownLabel.
  ///
  /// In id, this message translates to:
  /// **'Belum ada informasi'**
  String get unknownLabel;

  /// No description provided for @laporanPertamaDiterima.
  ///
  /// In id, this message translates to:
  /// **'Laporan pertama diterima'**
  String get laporanPertamaDiterima;

  /// No description provided for @kasusDibuatDariKonsolidasi.
  ///
  /// In id, this message translates to:
  /// **'Kasus dibuat dari konsolidasi'**
  String get kasusDibuatDariKonsolidasi;

  /// No description provided for @laporanDigabung.
  ///
  /// In id, this message translates to:
  /// **'Laporan digabung'**
  String get laporanDigabung;

  /// No description provided for @menungguVerifikasiManual.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi manual'**
  String get menungguVerifikasiManual;

  /// No description provided for @laporanNav.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get laporanNav;

  /// No description provided for @sinkronNav.
  ///
  /// In id, this message translates to:
  /// **'Sinkron'**
  String get sinkronNav;

  /// No description provided for @riwayatNav.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get riwayatNav;

  /// No description provided for @akunNav.
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get akunNav;

  /// No description provided for @buatLaporanFAB.
  ///
  /// In id, this message translates to:
  /// **'Buat laporan'**
  String get buatLaporanFAB;

  /// No description provided for @izinkanLokasiDitolakSnack.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak'**
  String get izinkanLokasiDitolakSnack;

  /// No description provided for @gagalCaptureGPS.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat membaca lokasi perangkat. Periksa izin lokasi dan coba lagi. Rincian: {error}'**
  String gagalCaptureGPS(String error);

  /// No description provided for @maksimal5Foto.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 5 foto'**
  String get maksimal5Foto;

  /// No description provided for @tambahFoto.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto ({count}/{max})'**
  String tambahFoto(int count, int max);

  /// No description provided for @formSurveiTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat hasil survei'**
  String get formSurveiTitle;

  /// No description provided for @kembaliKeDaftarTugasBtn.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Daftar Tugas'**
  String get kembaliKeDaftarTugasBtn;

  /// No description provided for @fotoPerSudut.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto dari setiap sudut'**
  String get fotoPerSudut;

  /// No description provided for @formSurveiHeader.
  ///
  /// In id, this message translates to:
  /// **'Catat kondisi di lokasi'**
  String get formSurveiHeader;

  /// No description provided for @gpsBelumTertangkap.
  ///
  /// In id, this message translates to:
  /// **'Anda belum merekam lokasi'**
  String get gpsBelumTertangkap;

  /// No description provided for @tidakDitemukanDiLokasi.
  ///
  /// In id, this message translates to:
  /// **'Saya tidak menemukan masalah di lokasi'**
  String get tidakDitemukanDiLokasi;

  /// No description provided for @ringkasanTab.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get ringkasanTab;

  /// No description provided for @buktiLaporanTab.
  ///
  /// In id, this message translates to:
  /// **'Bukti & Laporan'**
  String get buktiLaporanTab;

  /// No description provided for @verifikasiTab.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi'**
  String get verifikasiTab;

  /// No description provided for @tugasProgresTab.
  ///
  /// In id, this message translates to:
  /// **'Tugas & Progres'**
  String get tugasProgresTab;

  /// No description provided for @riwayatAuditTab.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Audit'**
  String get riwayatAuditTab;

  /// No description provided for @aksiGunakanPanelVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Aksi \"{label}\" - gunakan panel verifikasi'**
  String aksiGunakanPanelVerifikasi(String label);

  /// No description provided for @bukaTabVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Buka tab Verifikasi untuk aksi \"{label}\"'**
  String bukaTabVerifikasi(String label);

  /// No description provided for @statusKasus.
  ///
  /// In id, this message translates to:
  /// **'Status Kasus'**
  String get statusKasus;

  /// No description provided for @daftarTugasProgres.
  ///
  /// In id, this message translates to:
  /// **'Daftar tugas dan progres penanganan akan ditampilkan di sini.'**
  String get daftarTugasProgres;

  /// No description provided for @riwayatAuditLabel.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Audit'**
  String get riwayatAuditLabel;

  /// No description provided for @detailAuditTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Audit'**
  String get detailAuditTitle;

  /// No description provided for @detailAuditDesc.
  ///
  /// In id, this message translates to:
  /// **'Detail lengkap audit chain akan ditampilkan di sini.'**
  String get detailAuditDesc;

  /// No description provided for @belumAdaRiwayatAudit.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat audit'**
  String get belumAdaRiwayatAudit;

  /// No description provided for @transisiStatusTidakValid.
  ///
  /// In id, this message translates to:
  /// **'Transisi status tidak valid. Laporan mungkin sudah diproses.'**
  String get transisiStatusTidakValid;

  /// No description provided for @gagalMengirimKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim keputusan: {error}'**
  String gagalMengirimKeputusan(String error);

  /// No description provided for @gagalMemuatError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat: {error}'**
  String gagalMemuatError(String error);

  /// No description provided for @errorLabel.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan: {error}'**
  String errorLabel(String error);

  /// No description provided for @andaTidakAksesVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses untuk memverifikasi kasus ini.'**
  String get andaTidakAksesVerifikasi;

  /// No description provided for @andaTidakAksesTugas.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses untuk melihat tugas kasus ini.'**
  String get andaTidakAksesTugas;

  /// No description provided for @andaTidakAksesAudit.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses untuk melihat riwayat audit.'**
  String get andaTidakAksesAudit;

  /// No description provided for @tidakAdaTugasTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Tugas'**
  String get tidakAdaTugasTitle;

  /// No description provided for @tugasPenangananMuncul.
  ///
  /// In id, this message translates to:
  /// **'Tugas penanganan untuk kasus ini akan muncul di sini.'**
  String get tugasPenangananMuncul;

  /// No description provided for @tidakAdaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada deskripsi.'**
  String get tidakAdaDeskripsi;

  /// No description provided for @koordinatLabel.
  ///
  /// In id, this message translates to:
  /// **'Koordinat: {lat}, {lng}'**
  String koordinatLabel(String lat, String lng);

  /// No description provided for @prioritasLabel.
  ///
  /// In id, this message translates to:
  /// **'Prioritas: {value}'**
  String prioritasLabel(String value);

  /// No description provided for @kembaliKeLaporan.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Laporan'**
  String get kembaliKeLaporan;

  /// No description provided for @batalBtn.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get batalBtn;

  /// No description provided for @idLaporanLabel.
  ///
  /// In id, this message translates to:
  /// **'Nomor laporan'**
  String get idLaporanLabel;

  /// No description provided for @apaItuSanggahan.
  ///
  /// In id, this message translates to:
  /// **'Apa itu Sanggahan?'**
  String get apaItuSanggahan;

  /// No description provided for @sanggahanAdalah.
  ///
  /// In id, this message translates to:
  /// **'Sanggahan adalah cara Anda untuk mengajukan keberatan terhadap keputusan penolakan.'**
  String get sanggahanAdalah;

  /// No description provided for @alasanSanggahanLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan Sanggahan'**
  String get alasanSanggahanLabel;

  /// No description provided for @wajibLabel.
  ///
  /// In id, this message translates to:
  /// **'WAJIB'**
  String get wajibLabel;

  /// No description provided for @karakterMinimum.
  ///
  /// In id, this message translates to:
  /// **'{current} / {minimum} karakter minimum'**
  String karakterMinimum(int current, int minimum);

  /// No description provided for @validLabel.
  ///
  /// In id, this message translates to:
  /// **'Valid'**
  String get validLabel;

  /// No description provided for @ajukanSanggahanBtn.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Sanggahan'**
  String get ajukanSanggahanBtn;

  /// No description provided for @gagalAjukanSanggahanError.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengajukan sanggahan: {error}'**
  String gagalAjukanSanggahanError(String error);

  /// No description provided for @sanggahanBerhasil.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah mengirim sanggahan'**
  String get sanggahanBerhasil;

  /// No description provided for @sanggahanBerhasilDesc.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menerima sanggahan untuk laporan {reportId}. Ikuti perkembangannya melalui detail laporan; pengiriman ini belum mengubah keputusan sebelumnya.'**
  String sanggahanBerhasilDesc(String reportId);

  /// No description provided for @filterAuditLog.
  ///
  /// In id, this message translates to:
  /// **'Filter log audit'**
  String get filterAuditLog;

  /// No description provided for @idUserNamaActor.
  ///
  /// In id, this message translates to:
  /// **'ID / Nama Pengguna (Actor)'**
  String get idUserNamaActor;

  /// No description provided for @idObjekResourceId.
  ///
  /// In id, this message translates to:
  /// **'ID Objek (Resource ID)'**
  String get idObjekResourceId;

  /// No description provided for @aksiAction.
  ///
  /// In id, this message translates to:
  /// **'Aksi (Action)'**
  String get aksiAction;

  /// No description provided for @tipeObjekResourceType.
  ///
  /// In id, this message translates to:
  /// **'Tipe Objek (Resource Type)'**
  String get tipeObjekResourceType;

  /// No description provided for @filterAktif.
  ///
  /// In id, this message translates to:
  /// **'Filter Aktif: '**
  String get filterAktif;

  /// No description provided for @aksiFilter.
  ///
  /// In id, this message translates to:
  /// **'Aksi: {value}'**
  String aksiFilter(String value);

  /// No description provided for @objekFilter.
  ///
  /// In id, this message translates to:
  /// **'Objek: {value}'**
  String objekFilter(String value);

  /// No description provided for @actorFilter.
  ///
  /// In id, this message translates to:
  /// **'Aktor: {value}'**
  String actorFilter(String value);

  /// No description provided for @tanggalTerpilih.
  ///
  /// In id, this message translates to:
  /// **'Tanggal: Terpilih'**
  String get tanggalTerpilih;

  /// No description provided for @detailPerubahanLabel.
  ///
  /// In id, this message translates to:
  /// **'Detail Perubahan: {action}'**
  String detailPerubahanLabel(String action);

  /// No description provided for @gagalMemuatAuditLog.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Audit Log'**
  String get gagalMemuatAuditLog;

  /// No description provided for @tidakAdaDataAuditLog.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Data Audit Log'**
  String get tidakAdaDataAuditLog;

  /// No description provided for @tidakDitemukanRiwayatLog.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan riwayat log dengan kriteria filter saat ini.'**
  String get tidakDitemukanRiwayatLog;

  /// No description provided for @belumAdaAktivitasTercatat.
  ///
  /// In id, this message translates to:
  /// **'Belum ada aktivitas yang tercatat di audit log.'**
  String get belumAdaAktivitasTercatat;

  /// No description provided for @lihatDetailPerubahanDiff.
  ///
  /// In id, this message translates to:
  /// **'Lihat detail perubahan (diff)'**
  String get lihatDetailPerubahanDiff;

  /// No description provided for @kosongTidakAdaData.
  ///
  /// In id, this message translates to:
  /// **'(Kosong / Tidak ada data)'**
  String get kosongTidakAdaData;

  /// No description provided for @wargaRole.
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get wargaRole;

  /// No description provided for @petugasRole.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get petugasRole;

  /// No description provided for @adminRole.
  ///
  /// In id, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @tidakAdaTugasSurvei.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Tugas Survei'**
  String get tidakAdaTugasSurvei;

  /// No description provided for @belumAdaTugas.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Tugas'**
  String get belumAdaTugas;

  /// No description provided for @detailTugasSurvei.
  ///
  /// In id, this message translates to:
  /// **'Detail Tugas Survei'**
  String get detailTugasSurvei;

  /// No description provided for @detailTugasPetugas.
  ///
  /// In id, this message translates to:
  /// **'Detail Tugas Petugas'**
  String get detailTugasPetugas;

  /// No description provided for @gagalMemuatDetailTugas.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Detail Tugas'**
  String get gagalMemuatDetailTugas;

  /// No description provided for @gagalMemuatTugasTitle.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Tugas'**
  String get gagalMemuatTugasTitle;

  /// No description provided for @urutkanLabel.
  ///
  /// In id, this message translates to:
  /// **'Urutkan: '**
  String get urutkanLabel;

  /// No description provided for @tugasHariIni.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini'**
  String get tugasHariIni;

  /// No description provided for @semuaTersinkronStatus.
  ///
  /// In id, this message translates to:
  /// **'Semua tersinkron'**
  String get semuaTersinkronStatus;

  /// No description provided for @tidakAdaDataMenungguSinkron.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data yang menunggu sinkron'**
  String get tidakAdaDataMenungguSinkron;

  /// No description provided for @gagalDikirimLabel.
  ///
  /// In id, this message translates to:
  /// **'Gagal dikirim'**
  String get gagalDikirimLabel;

  /// No description provided for @menungguLabel.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get menungguLabel;

  /// No description provided for @gagalLabel.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get gagalLabel;

  /// No description provided for @kasusKritisTitle.
  ///
  /// In id, this message translates to:
  /// **'Kasus Kritis'**
  String get kasusKritisTitle;

  /// No description provided for @tidakAdaKasusKritis.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kasus kritis'**
  String get tidakAdaKasusKritis;

  /// No description provided for @gagalMemuatPetaError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat peta'**
  String get gagalMemuatPetaError;

  /// No description provided for @statusMarker.
  ///
  /// In id, this message translates to:
  /// **'Status: {status}'**
  String statusMarker(String status);

  /// No description provided for @kategoriSection.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get kategoriSection;

  /// No description provided for @statusSection.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get statusSection;

  /// No description provided for @waktuSection.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get waktuSection;

  /// No description provided for @pengaturanTooltip.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get pengaturanTooltip;

  /// No description provided for @wargaDefault.
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get wargaDefault;

  /// No description provided for @apakahYakinKeluar.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar dari sesi akun ini?'**
  String get apakahYakinKeluar;

  /// No description provided for @bahasaIndonesiaLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesiaLabel;

  /// No description provided for @statusServer.
  ///
  /// In id, this message translates to:
  /// **'Status Server'**
  String get statusServer;

  /// No description provided for @onlineTersambung.
  ///
  /// In id, this message translates to:
  /// **'Online (Tersambung)'**
  String get onlineTersambung;

  /// No description provided for @cobaLagiBtn.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get cobaLagiBtn;

  /// No description provided for @aksesDitolakTitle.
  ///
  /// In id, this message translates to:
  /// **'Akses Ditolak'**
  String get aksesDitolakTitle;

  /// No description provided for @tutupBtn.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get tutupBtn;

  /// No description provided for @tentangPrivasi.
  ///
  /// In id, this message translates to:
  /// **'Tentang Privasi'**
  String get tentangPrivasi;

  /// No description provided for @privasiInfoBody.
  ///
  /// In id, this message translates to:
  /// **'Identitas dan lokasi presisi Anda hanya terlihat oleh petugas terkait. Publik hanya melihat lokasi yang digeneralisasi.'**
  String get privasiInfoBody;

  /// No description provided for @identitasPublik.
  ///
  /// In id, this message translates to:
  /// **'Identitas saya di publik'**
  String get identitasPublik;

  /// No description provided for @prioritasRendah.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get prioritasRendah;

  /// No description provided for @prioritasTinggi.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get prioritasTinggi;

  /// No description provided for @prioritasDiubah.
  ///
  /// In id, this message translates to:
  /// **'Prioritas diubah'**
  String get prioritasDiubah;

  /// No description provided for @rendahLabel.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get rendahLabel;

  /// No description provided for @tinggiLabel.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get tinggiLabel;

  /// No description provided for @siapOfflineBadge.
  ///
  /// In id, this message translates to:
  /// **'Siap offline'**
  String get siapOfflineBadge;

  /// No description provided for @unduhUntukOffline.
  ///
  /// In id, this message translates to:
  /// **'Unduh untuk offline'**
  String get unduhUntukOffline;

  /// No description provided for @prioritasTinggiCard.
  ///
  /// In id, this message translates to:
  /// **'Prioritas tinggi'**
  String get prioritasTinggiCard;

  /// No description provided for @prioritasSedangCard.
  ///
  /// In id, this message translates to:
  /// **'Prioritas sedang'**
  String get prioritasSedangCard;

  /// No description provided for @prioritasNormalCard.
  ///
  /// In id, this message translates to:
  /// **'Prioritas normal'**
  String get prioritasNormalCard;

  /// No description provided for @prioritasRendahCard.
  ///
  /// In id, this message translates to:
  /// **'Prioritas rendah'**
  String get prioritasRendahCard;

  /// No description provided for @tugasHariIniTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini'**
  String get tugasHariIniTitle;

  /// No description provided for @umurBacklogTitle.
  ///
  /// In id, this message translates to:
  /// **'Umur backlog kasus'**
  String get umurBacklogTitle;

  /// No description provided for @unduhBatchBtn.
  ///
  /// In id, this message translates to:
  /// **'Unduh batch'**
  String get unduhBatchBtn;

  /// No description provided for @kasusKritisDefault.
  ///
  /// In id, this message translates to:
  /// **'Kasus kritis'**
  String get kasusKritisDefault;

  /// No description provided for @kasusTerdekatTitle.
  ///
  /// In id, this message translates to:
  /// **'Kasus terdekat'**
  String get kasusTerdekatTitle;

  /// No description provided for @lihatPetaAction.
  ///
  /// In id, this message translates to:
  /// **'Lihat peta'**
  String get lihatPetaAction;

  /// No description provided for @sedangDitanganiStatus.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditangani'**
  String get sedangDitanganiStatus;

  /// No description provided for @terverifikasiStatus.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get terverifikasiStatus;

  /// No description provided for @lokasiGPS.
  ///
  /// In id, this message translates to:
  /// **'Lokasi GPS'**
  String get lokasiGPS;

  /// No description provided for @catatanLapangan.
  ///
  /// In id, this message translates to:
  /// **'Catatan lapangan'**
  String get catatanLapangan;

  /// No description provided for @tambahkanCatatan.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan catatan...'**
  String get tambahkanCatatan;

  /// No description provided for @batasWaktuBelumDipilih.
  ///
  /// In id, this message translates to:
  /// **'Batas Waktu: (belum dipilih)'**
  String get batasWaktuBelumDipilih;

  /// No description provided for @batasWaktuLabel.
  ///
  /// In id, this message translates to:
  /// **'Batas Waktu: {time}'**
  String batasWaktuLabel(String time);

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan: {error}'**
  String errorGeneric(String error);

  /// No description provided for @simpanDanSinkronkanNantiBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan sinkronkan nanti'**
  String get simpanDanSinkronkanNantiBtn;

  /// No description provided for @tidakAdaKoneksiAntrean.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi — laporan akan masuk antrean.'**
  String get tidakAdaKoneksiAntrean;

  /// No description provided for @tambahkanBuktiKeKasus.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan bukti ke kasus ini'**
  String get tambahkanBuktiKeKasus;

  /// No description provided for @buatTerpisah.
  ///
  /// In id, this message translates to:
  /// **'Buat terpisah'**
  String get buatTerpisah;

  /// No description provided for @lanjutKeReviewHasilSurvei.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke review hasil survei'**
  String get lanjutKeReviewHasilSurvei;

  /// No description provided for @mintaClarifikasiBtn.
  ///
  /// In id, this message translates to:
  /// **'Minta Clarifikasi'**
  String get mintaClarifikasiBtn;

  /// No description provided for @terimaTugasBtn.
  ///
  /// In id, this message translates to:
  /// **'Terima Tugas'**
  String get terimaTugasBtn;

  /// No description provided for @sinkronkanSekarang.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan Sekarang'**
  String get sinkronkanSekarang;

  /// No description provided for @sinkronkanSekarangSemantics.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan sekarang'**
  String get sinkronkanSekarangSemantics;

  /// No description provided for @petaAreaBuktiDiunduh.
  ///
  /// In id, this message translates to:
  /// **'Peta area + bukti diunduh'**
  String get petaAreaBuktiDiunduh;

  /// No description provided for @duplicateCandidates.
  ///
  /// In id, this message translates to:
  /// **'Kandidat Duplikat'**
  String get duplicateCandidates;

  /// No description provided for @menungguVerifikasiSnackBar.
  ///
  /// In id, this message translates to:
  /// **'Menunggu Verifikasi'**
  String get menungguVerifikasiSnackBar;

  /// No description provided for @terverifikasiSnackBar.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get terverifikasiSnackBar;

  /// No description provided for @sedangDitanganiSnackBar.
  ///
  /// In id, this message translates to:
  /// **'Sedang Ditangani'**
  String get sedangDitanganiSnackBar;

  /// No description provided for @perluKelengkapanSnackBar.
  ///
  /// In id, this message translates to:
  /// **'Perlu Kelengkapan'**
  String get perluKelengkapanSnackBar;

  /// No description provided for @slaTerlewatSnackBar.
  ///
  /// In id, this message translates to:
  /// **'SLA Terlewat'**
  String get slaTerlewatSnackBar;

  /// No description provided for @submittedLabel.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi'**
  String get submittedLabel;

  /// No description provided for @underReviewLabel.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get underReviewLabel;

  /// No description provided for @inProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditangani'**
  String get inProgressLabel;

  /// No description provided for @resolvedLabel.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get resolvedLabel;

  /// No description provided for @rejectedLabel.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get rejectedLabel;

  /// No description provided for @verifiedLabel.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get verifiedLabel;

  /// No description provided for @kualitasData.
  ///
  /// In id, this message translates to:
  /// **'Kualitas Data'**
  String get kualitasData;

  /// No description provided for @tingkatSinkronisasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Sinkronisasi'**
  String get tingkatSinkronisasiLabel;

  /// No description provided for @surveyorMenungguLabel.
  ///
  /// In id, this message translates to:
  /// **'Petugas Menunggu'**
  String get surveyorMenungguLabel;

  /// No description provided for @risikoSLA.
  ///
  /// In id, this message translates to:
  /// **'Risiko SLA'**
  String get risikoSLA;

  /// No description provided for @semuaKasusOnTrack.
  ///
  /// In id, this message translates to:
  /// **'Semua kasus on track'**
  String get semuaKasusOnTrack;

  /// No description provided for @pendahLabel.
  ///
  /// In id, this message translates to:
  /// **'Pendah'**
  String get pendahLabel;

  /// No description provided for @sinkronisasiBerhasil.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi Berhasil'**
  String get sinkronisasiBerhasil;

  /// No description provided for @dataBerhasilDisinkronkan.
  ///
  /// In id, this message translates to:
  /// **'Data berhasil disinkronkan ke server'**
  String get dataBerhasilDisinkronkan;

  /// No description provided for @sinkronisasiGagal.
  ///
  /// In id, this message translates to:
  /// **'Sinkronisasi Gagal'**
  String get sinkronisasiGagal;

  /// No description provided for @gagalMenyinkronkanData.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyinkronkan data. Silakan coba lagi.'**
  String get gagalMenyinkronkanData;

  /// No description provided for @itemGagalDisinkronkan.
  ///
  /// In id, this message translates to:
  /// **'Item gagal disinkronkan'**
  String get itemGagalDisinkronkan;

  /// No description provided for @exportFormat.
  ///
  /// In id, this message translates to:
  /// **'Format Export'**
  String get exportFormat;

  /// No description provided for @exportCSVGagal.
  ///
  /// In id, this message translates to:
  /// **'Export CSV gagal:'**
  String get exportCSVGagal;

  /// No description provided for @exportGeoJSONGagal.
  ///
  /// In id, this message translates to:
  /// **'Export GeoJSON gagal:'**
  String get exportGeoJSONGagal;

  /// No description provided for @exportPDFGagal.
  ///
  /// In id, this message translates to:
  /// **'Export PDF gagal:'**
  String get exportPDFGagal;

  /// No description provided for @emptyGeoJSON.
  ///
  /// In id, this message translates to:
  /// **'GeoJSON kosong'**
  String get emptyGeoJSON;

  /// No description provided for @sigapMobile.
  ///
  /// In id, this message translates to:
  /// **'SIGAP Mobile'**
  String get sigapMobile;

  /// No description provided for @sistemInformasiGerakAduan.
  ///
  /// In id, this message translates to:
  /// **'Sistem Informasi Geospasial & Penanganan Laporan Publik'**
  String get sistemInformasiGerakAduan;

  /// No description provided for @versiAplikasi.
  ///
  /// In id, this message translates to:
  /// **'v1.0.0'**
  String get versiAplikasi;

  /// No description provided for @batalkanTugasTitle.
  ///
  /// In id, this message translates to:
  /// **'Tolak Tugas'**
  String get batalkanTugasTitle;

  /// No description provided for @alasanPenolakanLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan penolakan'**
  String get alasanPenolakanLabel;

  /// No description provided for @masukkanAlasanHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alasan...'**
  String get masukkanAlasanHint;

  /// No description provided for @mintaClarifikasiTitle.
  ///
  /// In id, this message translates to:
  /// **'Minta Clarifikasi'**
  String get mintaClarifikasiTitle;

  /// No description provided for @pertanyaanKlarifikasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan / klarifikasi'**
  String get pertanyaanKlarifikasiLabel;

  /// No description provided for @tulisPertanyaanHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis pertanyaan Anda...'**
  String get tulisPertanyaanHint;

  /// No description provided for @kondisiAktual.
  ///
  /// In id, this message translates to:
  /// **'Pilih kondisi yang Anda lihat'**
  String get kondisiAktual;

  /// No description provided for @rekomendasiHasil.
  ///
  /// In id, this message translates to:
  /// **'Sarankan tindak lanjut'**
  String get rekomendasiHasil;

  /// No description provided for @ambilGPS.
  ///
  /// In id, this message translates to:
  /// **'Rekam lokasi perangkat'**
  String get ambilGPS;

  /// No description provided for @pilihPeranKonteks.
  ///
  /// In id, this message translates to:
  /// **'Pilih peran untuk berganti konteks kerja. Menu, alur data, dan izin akses akan disesuaikan secara otomatis.'**
  String get pilihPeranKonteks;

  /// No description provided for @kirimLaporanPublik.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan pengaduan publik dan pantau status penyelesaian.'**
  String get kirimLaporanPublik;

  /// No description provided for @ringkasanEksekutif.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan eksekutif, analisis tren verifikasi, dan statistik.'**
  String get ringkasanEksekutif;

  /// No description provided for @gagalMemuatAssessment.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Assessment'**
  String get gagalMemuatAssessment;

  /// No description provided for @belumAdaAssessmentAI.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Assessment AI'**
  String get belumAdaAssessmentAI;

  /// No description provided for @formatExportTitle.
  ///
  /// In id, this message translates to:
  /// **'Format Export'**
  String get formatExportTitle;

  /// No description provided for @riwayatAuditImmutable.
  ///
  /// In id, this message translates to:
  /// **'Riwayat audit bersifat immutable dan tidak dapat diubah. '**
  String get riwayatAuditImmutable;

  /// No description provided for @kategoriColon.
  ///
  /// In id, this message translates to:
  /// **'Kategori:'**
  String get kategoriColon;

  /// No description provided for @deskripsiColon.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi:'**
  String get deskripsiColon;

  /// No description provided for @fotoColon.
  ///
  /// In id, this message translates to:
  /// **'Foto:'**
  String get fotoColon;

  /// No description provided for @buktiFotoDariPelapor.
  ///
  /// In id, this message translates to:
  /// **'Bukti foto kerusakan dari pelapor'**
  String get buktiFotoDariPelapor;

  /// No description provided for @koordinatColon.
  ///
  /// In id, this message translates to:
  /// **'Koordinat:'**
  String get koordinatColon;

  /// No description provided for @lokasiTepatDiPeta.
  ///
  /// In id, this message translates to:
  /// **'Lokasi tepat di peta'**
  String get lokasiTepatDiPeta;

  /// No description provided for @tanggalColon.
  ///
  /// In id, this message translates to:
  /// **'Tanggal:'**
  String get tanggalColon;

  /// No description provided for @kapanLaporanDibuat.
  ///
  /// In id, this message translates to:
  /// **'Kapan laporan dibuat'**
  String get kapanLaporanDibuat;

  /// No description provided for @statusLaporan.
  ///
  /// In id, this message translates to:
  /// **'Status Laporan'**
  String get statusLaporan;

  /// No description provided for @laporanBaru.
  ///
  /// In id, this message translates to:
  /// **'Laporan baru'**
  String get laporanBaru;

  /// No description provided for @perluTindakanStatus.
  ///
  /// In id, this message translates to:
  /// **'Perlu Tindakan'**
  String get perluTindakanStatus;

  /// No description provided for @sedangDiprosesStatus.
  ///
  /// In id, this message translates to:
  /// **'Sedang Diproses'**
  String get sedangDiprosesStatus;

  /// No description provided for @selesaiStatus.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get selesaiStatus;

  /// No description provided for @ditolakStatus.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get ditolakStatus;

  /// No description provided for @keteranganPrivasiTooltip.
  ///
  /// In id, this message translates to:
  /// **'Jika aktif, nama Anda terlihat oleh publik. Lokasi tetap digeneralisasi.'**
  String get keteranganPrivasiTooltip;

  /// No description provided for @identitasLokasiPrivasi.
  ///
  /// In id, this message translates to:
  /// **'Identitas dan lokasi presisi Anda hanya terlihat oleh petugas terkait. Publik hanya melihat lokasi yang digeneralisasi.'**
  String get identitasLokasiPrivasi;

  /// No description provided for @gpsBadge.
  ///
  /// In id, this message translates to:
  /// **'GPS'**
  String get gpsBadge;

  /// No description provided for @maks5FotoFormat.
  ///
  /// In id, this message translates to:
  /// **'Maks 5 foto, format JPG/PNG. GPS dari EXIF akan digunakan jika tersedia.'**
  String get maks5FotoFormat;

  /// No description provided for @jamSuffix.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get jamSuffix;

  /// No description provided for @aktifStatus.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get aktifStatus;

  /// No description provided for @nonaktifStatus.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get nonaktifStatus;

  /// No description provided for @targetJam.
  ///
  /// In id, this message translates to:
  /// **'Target: {hours} jam'**
  String targetJam(int hours);

  /// No description provided for @slugPrefix.
  ///
  /// In id, this message translates to:
  /// **'Slug: {value}'**
  String slugPrefix(String value);

  /// No description provided for @latihanVerifikasiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Pelatihan Verifikasi Laporan'**
  String get latihanVerifikasiLaporan;

  /// No description provided for @apaItuSIGAP.
  ///
  /// In id, this message translates to:
  /// **'Apa itu SIGAP?'**
  String get apaItuSIGAP;

  /// No description provided for @tujuanSIGAP.
  ///
  /// In id, this message translates to:
  /// **'Tujuan SIGAP'**
  String get tujuanSIGAP;

  /// No description provided for @caraMemverifikasiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Cara Memverifikasi Laporan'**
  String get caraMemverifikasiLaporan;

  /// No description provided for @terimaTautanVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Terima Tautan Verifikasi'**
  String get terimaTautanVerifikasi;

  /// No description provided for @bukaTautan.
  ///
  /// In id, this message translates to:
  /// **'Buka Tautan'**
  String get bukaTautan;

  /// No description provided for @periksaKondisiLapangan.
  ///
  /// In id, this message translates to:
  /// **'Periksa Kondisi di Lapangan'**
  String get periksaKondisiLapangan;

  /// No description provided for @berikanKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Berikan Keputusan'**
  String get berikanKeputusan;

  /// No description provided for @kirimVerifikasiTitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim Verifikasi'**
  String get kirimVerifikasiTitle;

  /// No description provided for @klikTombolKirimVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Klik tombol \'Kirim Verifikasi\' untuk mengirimkan keputusan Anda ke sistem.'**
  String get klikTombolKirimVerifikasi;

  /// No description provided for @memahamiDashboardSIGAP.
  ///
  /// In id, this message translates to:
  /// **'Memahami Dashboard SIGAP'**
  String get memahamiDashboardSIGAP;

  /// No description provided for @dashboardMenampilkanLaporan.
  ///
  /// In id, this message translates to:
  /// **'Dashboard SIGAP menampilkan semua laporan kerusakan yang masuk.'**
  String get dashboardMenampilkanLaporan;

  /// No description provided for @bestPractice.
  ///
  /// In id, this message translates to:
  /// **'Praktik terbaik'**
  String get bestPractice;

  /// No description provided for @lakukan.
  ///
  /// In id, this message translates to:
  /// **'Lakukan'**
  String get lakukan;

  /// No description provided for @verifikasiDalam1x24Jam.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi laporan dalam 1x24 jam'**
  String get verifikasiDalam1x24Jam;

  /// No description provided for @hindari.
  ///
  /// In id, this message translates to:
  /// **'Hindari'**
  String get hindari;

  /// No description provided for @pertanyaanUmum.
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan Umum'**
  String get pertanyaanUmum;

  /// No description provided for @statusDikonfirmasi.
  ///
  /// In id, this message translates to:
  /// **'Dikonfirmasi'**
  String get statusDikonfirmasi;

  /// No description provided for @statusDitolakRT.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get statusDitolakRT;

  /// No description provided for @laporanTidakValid.
  ///
  /// In id, this message translates to:
  /// **'Laporan tidak valid'**
  String get laporanTidakValid;

  /// No description provided for @berikanAlasanJelas.
  ///
  /// In id, this message translates to:
  /// **'Berikan alasan yang jelas'**
  String get berikanAlasanJelas;

  /// No description provided for @simpanKonfigurasiBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan Konfigurasi'**
  String get simpanKonfigurasiBtn;

  /// No description provided for @editSLATooltip.
  ///
  /// In id, this message translates to:
  /// **'Edit SLA'**
  String get editSLATooltip;

  /// No description provided for @segarkanTooltip.
  ///
  /// In id, this message translates to:
  /// **'Segarkan'**
  String get segarkanTooltip;

  /// No description provided for @antreanNav.
  ///
  /// In id, this message translates to:
  /// **'Antrean'**
  String get antreanNav;

  /// No description provided for @exportNav.
  ///
  /// In id, this message translates to:
  /// **'Ekspor'**
  String get exportNav;

  /// No description provided for @analitikNav.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get analitikNav;

  /// No description provided for @dashboardEksekutif.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Eksekutif'**
  String get dashboardEksekutif;

  /// No description provided for @masukkanPertanyaanInformasiHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan pertanyaan atau informasi yang diperlukan...'**
  String get masukkanPertanyaanInformasiHint;

  /// No description provided for @diajukanPada.
  ///
  /// In id, this message translates to:
  /// **'Diajukan: {date}'**
  String diajukanPada(String date);

  /// No description provided for @olehPelaku.
  ///
  /// In id, this message translates to:
  /// **'oleh: {userId}'**
  String olehPelaku(String userId);

  /// No description provided for @verifikasiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Laporan'**
  String get verifikasiLaporan;

  /// No description provided for @panduanLengkapRTRW.
  ///
  /// In id, this message translates to:
  /// **'Panduan lengkap untuk pejabat RT dan RW dalam menggunakan sistem SIGAP'**
  String get panduanLengkapRTRW;

  /// No description provided for @deskripsiSIGAP.
  ///
  /// In id, this message translates to:
  /// **'SIGAP (Sistem Informasi Geospasial & Penanganan Laporan Desa) adalah platform digital untuk pemetaan dan pemantauan pembangunan desa. Sistem ini membantu mencatat, melacak, dan menyelesaikan laporan kerusakan infrastruktur di lingkungan Anda.'**
  String get deskripsiSIGAP;

  /// No description provided for @memetakanKerusakan.
  ///
  /// In id, this message translates to:
  /// **'Memetakan kerusakan infrastruktur'**
  String get memetakanKerusakan;

  /// No description provided for @mempercepatPerbaikan.
  ///
  /// In id, this message translates to:
  /// **'Mempercepat proses perbaikan'**
  String get mempercepatPerbaikan;

  /// No description provided for @transparansiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Transparansi laporan masyarakat'**
  String get transparansiLaporan;

  /// No description provided for @koordinasiPemerintah.
  ///
  /// In id, this message translates to:
  /// **'Koordinasi antar tingkat pemerintah'**
  String get koordinasiPemerintah;

  /// No description provided for @memverifikasiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Memverifikasi laporan kerusakan'**
  String get memverifikasiLaporan;

  /// No description provided for @memberikanKonfirmasi.
  ///
  /// In id, this message translates to:
  /// **'Memberikan konfirmasi di lapangan'**
  String get memberikanKonfirmasi;

  /// No description provided for @melaporkanKerusakanBaru.
  ///
  /// In id, this message translates to:
  /// **'Melaporkan kerusakan baru'**
  String get melaporkanKerusakanBaru;

  /// No description provided for @memantauStatusPerbaikan.
  ///
  /// In id, this message translates to:
  /// **'Memantau status perbaikan'**
  String get memantauStatusPerbaikan;

  /// No description provided for @deskripsiTerimaTautan.
  ///
  /// In id, this message translates to:
  /// **'Anda akan menerima tautan verifikasi melalui SMS atau WhatsApp dari sistem SIGAP. Tautan berisi token unik untuk mengakses laporan.'**
  String get deskripsiTerimaTautan;

  /// No description provided for @deskripsiBukaTautan.
  ///
  /// In id, this message translates to:
  /// **'Klik tautan yang dikirimkan. Anda akan diarahkan ke halaman verifikasi SIGAP.'**
  String get deskripsiBukaTautan;

  /// No description provided for @deskripsiPeriksaKondisi.
  ///
  /// In id, this message translates to:
  /// **'Kunjungi lokasi yang disebutkan dalam laporan. Periksa apakah kerusakan benar-benar ada dan catat kondisi sebenarnya.'**
  String get deskripsiPeriksaKondisi;

  /// No description provided for @deskripsiBerikanKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Pilih \'Dikonfirmasi\' jika kerusakan benar ada, atau \'Ditolak\' jika laporan tidak valid. Berikan alasan yang jelas.'**
  String get deskripsiBerikanKeputusan;

  /// No description provided for @deskripsiKirimVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Klik tombol \'Kirim Verifikasi\' untuk mengirimkan keputusan Anda ke sistem.'**
  String get deskripsiKirimVerifikasi;

  /// No description provided for @deskripsiMemahamiDashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard SIGAP menampilkan semua laporan kerusakan yang masuk. Berikut elemen-elemen utama yang perlu Anda ketahui:'**
  String get deskripsiMemahamiDashboard;

  /// No description provided for @datangLangsungKeLokasi.
  ///
  /// In id, this message translates to:
  /// **'Datang langsung ke lokasi'**
  String get datangLangsungKeLokasi;

  /// No description provided for @berikanAlasanDetail.
  ///
  /// In id, this message translates to:
  /// **'Berikan alasan yang detail'**
  String get berikanAlasanDetail;

  /// No description provided for @dokumentasikanDenganFoto.
  ///
  /// In id, this message translates to:
  /// **'Dokumentasikan dengan foto'**
  String get dokumentasikanDenganFoto;

  /// No description provided for @laporkanJikaKendala.
  ///
  /// In id, this message translates to:
  /// **'Laporkan jika ada kendala'**
  String get laporkanJikaKendala;

  /// No description provided for @memverifikasiTanpaKeLokasi.
  ///
  /// In id, this message translates to:
  /// **'Memverifikasi tanpa ke lokasi'**
  String get memverifikasiTanpaKeLokasi;

  /// No description provided for @memberikanAlasanKosong.
  ///
  /// In id, this message translates to:
  /// **'Memberikan alasan kosong'**
  String get memberikanAlasanKosong;

  /// No description provided for @menundaVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Menunda verifikasi terlalu lama'**
  String get menundaVerifikasi;

  /// No description provided for @menolakTanpaAlasan.
  ///
  /// In id, this message translates to:
  /// **'Menolak tanpa alasan jelas'**
  String get menolakTanpaAlasan;

  /// No description provided for @mengabaikanLaporan.
  ///
  /// In id, this message translates to:
  /// **'Mengabaikan laporan masyarakat'**
  String get mengabaikanLaporan;

  /// No description provided for @faqLokasiSulitDiakses.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana jika lokasi sulit diakses?'**
  String get faqLokasiSulitDiakses;

  /// No description provided for @faqLokasiSulitDiaksesJawab.
  ///
  /// In id, this message translates to:
  /// **'Coba verifikasi dari titik terdekat yang memungkinkan. Jika benar-benar tidak bisa diakses, berikan alasan di sistem dan minta bantuan tetangga atau warga sekitar untuk dokumentasi.'**
  String get faqLokasiSulitDiaksesJawab;

  /// No description provided for @faqLaporanTidakJelasPertanyaan.
  ///
  /// In id, this message translates to:
  /// **'Apa yang harus dilakukan jika laporan tidak jelas?'**
  String get faqLaporanTidakJelasPertanyaan;

  /// No description provided for @faqLaporanTidakJelasJawab.
  ///
  /// In id, this message translates to:
  /// **'Hubungi pelapor melalui nomor yang tertera untuk meminta klarifikasi. Jika tidak bisa dihubungi, verifikasi berdasarkan informasi yang ada dan catat ketidakjelasan tersebut.'**
  String get faqLaporanTidakJelasJawab;

  /// No description provided for @faqWaktuVerifikasiPertanyaan.
  ///
  /// In id, this message translates to:
  /// **'Berapa lama waktu verifikasi?'**
  String get faqWaktuVerifikasiPertanyaan;

  /// No description provided for @faqWaktuVerifikasiJawab.
  ///
  /// In id, this message translates to:
  /// **'Idealnya, verifikasi dilakukan dalam 1x24 jam setelah laporan masuk. Namun, jika ada kendala, segera hubungi admin daerah.'**
  String get faqWaktuVerifikasiJawab;

  /// No description provided for @faqTidakSetujuPertanyaan.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana jika saya tidak setuju dengan keputusan petugas?'**
  String get faqTidakSetujuPertanyaan;

  /// No description provided for @faqTidakSetujuJawab.
  ///
  /// In id, this message translates to:
  /// **'Setiap keputusan sudah tercatat dalam sistem. Jika ada keberatan, silakan hubungi admin daerah atau sampaikan melalui fitur komentar yang tersedia.'**
  String get faqTidakSetujuJawab;

  /// No description provided for @siapMemulai.
  ///
  /// In id, this message translates to:
  /// **'Siap Memulai?'**
  String get siapMemulai;

  /// No description provided for @aksesMenuVerifikasi.
  ///
  /// In id, this message translates to:
  /// **'Akses menu Verifikasi Laporan untuk memproses laporan kerusakan dari masyarakat.'**
  String get aksesMenuVerifikasi;

  /// No description provided for @pelatihanSelesai.
  ///
  /// In id, this message translates to:
  /// **'Pelatihan Selesai'**
  String get pelatihanSelesai;

  /// No description provided for @dalamPenanganan.
  ///
  /// In id, this message translates to:
  /// **'Dalam penanganan'**
  String get dalamPenanganan;

  /// No description provided for @sudahDiperbaiki.
  ///
  /// In id, this message translates to:
  /// **'Sudah diperbaiki'**
  String get sudahDiperbaiki;

  /// No description provided for @informasiLaporan.
  ///
  /// In id, this message translates to:
  /// **'Informasi Laporan'**
  String get informasiLaporan;

  /// No description provided for @sanggahanDeskripsiLengkap.
  ///
  /// In id, this message translates to:
  /// **'Ajukan sanggahan jika Anda memiliki alasan atau bukti untuk meminta peninjauan ulang keputusan laporan. Jelaskan bagian keputusan yang Anda pertanyakan dan informasi yang perlu petugas periksa kembali.'**
  String get sanggahanDeskripsiLengkap;

  /// No description provided for @jelaskanAlasanSanggahanHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan alasan sanggahan Anda secara detail...\n\nMinimal {count} karakter.'**
  String jelaskanAlasanSanggahanHint(int count);

  /// No description provided for @rentangTanggalSemua.
  ///
  /// In id, this message translates to:
  /// **'Rentang Tanggal: (Semua)'**
  String get rentangTanggalSemua;

  /// No description provided for @olehLabel.
  ///
  /// In id, this message translates to:
  /// **'Oleh: {actor}'**
  String olehLabel(String actor);

  /// No description provided for @tugasCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Tugas'**
  String tugasCount(int count);

  /// No description provided for @ditugaskanPada.
  ///
  /// In id, this message translates to:
  /// **'Ditugaskan: {date}'**
  String ditugaskanPada(String date);

  /// No description provided for @entriAuditCount.
  ///
  /// In id, this message translates to:
  /// **'{count} Entri Audit'**
  String entriAuditCount(int count);

  /// No description provided for @riwayatAuditInfo.
  ///
  /// In id, this message translates to:
  /// **'Riwayat audit bersifat immutable dan tidak dapat diubah. Semua tindakan pada kasus ini dicatat untuk keperluan audit.'**
  String get riwayatAuditInfo;

  /// No description provided for @semuaTindakanTercatatDiSini.
  ///
  /// In id, this message translates to:
  /// **'Semua tindakan pada kasus ini akan dicatat di sini.'**
  String get semuaTindakanTercatatDiSini;

  /// No description provided for @resourceLabel.
  ///
  /// In id, this message translates to:
  /// **'Sumber daya: {resource}'**
  String resourceLabel(String resource);

  /// No description provided for @gpsBerhasilDitangkap.
  ///
  /// In id, this message translates to:
  /// **'Perangkat merekam titik {lat}, {lng}. Periksa apakah titik sesuai lokasi survei.'**
  String gpsBerhasilDitangkap(String lat, String lng);

  /// No description provided for @gagalMemilihGambar.
  ///
  /// In id, this message translates to:
  /// **'Gagal memilih gambar: {error}'**
  String gagalMemilihGambar(String error);

  /// No description provided for @ringan.
  ///
  /// In id, this message translates to:
  /// **'Ringan'**
  String get ringan;

  /// No description provided for @kritis.
  ///
  /// In id, this message translates to:
  /// **'Kritis'**
  String get kritis;

  /// No description provided for @validPerluTindakLanjut.
  ///
  /// In id, this message translates to:
  /// **'Masalah masih memerlukan penanganan'**
  String get validPerluTindakLanjut;

  /// No description provided for @kondisiColonLabel.
  ///
  /// In id, this message translates to:
  /// **'Kondisi: {value}'**
  String kondisiColonLabel(String value);

  /// No description provided for @rekomendasiColonLabel.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi: {value}'**
  String rekomendasiColonLabel(String value);

  /// No description provided for @dataSurveiTersimpanLokal.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan hasil survei di perangkat ini. Buka pusat sinkronisasi saat internet tersedia untuk memeriksa pengirimannya.'**
  String get dataSurveiTersimpanLokal;

  /// No description provided for @dataSurveiTersimpanDiproses.
  ///
  /// In id, this message translates to:
  /// **'SIGAP telah menerima hasil survei Anda. Admin akan meninjau catatan dan foto sebelum menentukan tindak lanjut.'**
  String get dataSurveiTersimpanDiproses;

  /// No description provided for @hintCatatanLapangan.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan temuan yang Anda lihat, pengukuran yang Anda lakukan, dan tindakan yang sudah Anda ambil.'**
  String get hintCatatanLapangan;

  /// No description provided for @labelOffline.
  ///
  /// In id, this message translates to:
  /// **'offline'**
  String get labelOffline;

  /// No description provided for @tambahFotoLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get tambahFotoLabel;

  /// No description provided for @ketukUntukMenangkapGps.
  ///
  /// In id, this message translates to:
  /// **'Rekam lokasi saat Anda berada di tempat pemeriksaan. Titik perangkat tidak menggantikan catatan kondisi lapangan.'**
  String get ketukUntukMenangkapGps;

  /// No description provided for @depan.
  ///
  /// In id, this message translates to:
  /// **'Depan'**
  String get depan;

  /// No description provided for @samping.
  ///
  /// In id, this message translates to:
  /// **'Samping'**
  String get samping;

  /// No description provided for @atas.
  ///
  /// In id, this message translates to:
  /// **'Atas'**
  String get atas;

  /// No description provided for @fotoCountDari.
  ///
  /// In id, this message translates to:
  /// **'{count} dari {total}'**
  String fotoCountDari(int count, int total);

  /// No description provided for @infoSerupa.
  ///
  /// In id, this message translates to:
  /// **'{distance} · kemiripan {similarity}% · {count} laporan'**
  String infoSerupa(String distance, int similarity, int count);

  /// No description provided for @tidakDapatTerhubungKeServer.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server.'**
  String get tidakDapatTerhubungKeServer;

  /// No description provided for @errorTidakDikenal.
  ///
  /// In id, this message translates to:
  /// **'Error tidak dikenal'**
  String get errorTidakDikenal;

  /// No description provided for @gagalRetryLoop.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari loop retry tak terduga'**
  String get gagalRetryLoop;

  /// No description provided for @gagalMemuatLaporanPublik.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat laporan publik'**
  String get gagalMemuatLaporanPublik;

  /// No description provided for @gagalMemuatKasusPublik.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat kasus publik'**
  String get gagalMemuatKasusPublik;

  /// No description provided for @gagalMemuatStatistikPublik.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat statistik publik'**
  String get gagalMemuatStatistikPublik;

  /// No description provided for @gagalMemuatMetadataBagikan.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat metadata berbagi'**
  String get gagalMemuatMetadataBagikan;

  /// No description provided for @fileFotoTidakDitemukan.
  ///
  /// In id, this message translates to:
  /// **'File foto tidak ditemukan: {path}'**
  String fileFotoTidakDitemukan(String path);

  /// No description provided for @uploadFotoGagal.
  ///
  /// In id, this message translates to:
  /// **'Upload foto gagal'**
  String get uploadFotoGagal;

  /// No description provided for @uploadFotoGagalUrl.
  ///
  /// In id, this message translates to:
  /// **'Upload foto gagal: tidak ada URL yang dikembalikan'**
  String get uploadFotoGagalUrl;

  /// No description provided for @jenisKerusakanDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Jenis kerusakan (jalan, drainase, jembatan, dll)'**
  String get jenisKerusakanDeskripsi;

  /// No description provided for @penjelasanDariPelapor.
  ///
  /// In id, this message translates to:
  /// **'Penjelasan detail dari pelapor'**
  String get penjelasanDariPelapor;

  /// No description provided for @rentangTanggalLabel.
  ///
  /// In id, this message translates to:
  /// **'Rentang Tanggal: {range}'**
  String rentangTanggalLabel(String range);

  /// No description provided for @auditLogExportSubjek.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Audit Log ({format})'**
  String auditLogExportSubjek(String format);

  /// No description provided for @penggunaSigap.
  ///
  /// In id, this message translates to:
  /// **'Pengguna SIGAP'**
  String get penggunaSigap;

  /// No description provided for @aktifkanLokasiUntukMelihatPeta.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan lokasi untuk melihat peta Anda'**
  String get aktifkanLokasiUntukMelihatPeta;

  /// No description provided for @dariTanggal.
  ///
  /// In id, this message translates to:
  /// **'Dari Tanggal'**
  String get dariTanggal;

  /// No description provided for @sampaiTanggal.
  ///
  /// In id, this message translates to:
  /// **'Sampai Tanggal'**
  String get sampaiTanggal;

  /// No description provided for @tugasAkanMunculDiSini.
  ///
  /// In id, this message translates to:
  /// **'Tugas akan muncul di sini'**
  String get tugasAkanMunculDiSini;

  /// No description provided for @laporanAndaKirimkanMuncul.
  ///
  /// In id, this message translates to:
  /// **'Laporan yang Anda kirim akan muncul di sini'**
  String get laporanAndaKirimkanMuncul;

  /// No description provided for @countMenunggu.
  ///
  /// In id, this message translates to:
  /// **'{count} menunggu'**
  String countMenunggu(int count);

  /// No description provided for @tugasTersimpanOfflineCount.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas tersimpan offline'**
  String tugasTersimpanOfflineCount(int count);

  /// No description provided for @labelLaporanChart.
  ///
  /// In id, this message translates to:
  /// **'laporan'**
  String get labelLaporanChart;

  /// No description provided for @labelKasusChart.
  ///
  /// In id, this message translates to:
  /// **'kasus'**
  String get labelKasusChart;

  /// No description provided for @tidakAdaDataTren.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data tren'**
  String get tidakAdaDataTren;

  /// No description provided for @petugasPerluDitugaskan.
  ///
  /// In id, this message translates to:
  /// **'{count} petugas perlu ditugaskan'**
  String petugasPerluDitugaskan(int count);

  /// No description provided for @kasusBerisikoTerlambat.
  ///
  /// In id, this message translates to:
  /// **'{count} kasus berisiko terlambat'**
  String kasusBerisikoTerlambat(int count);

  /// No description provided for @overdue.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get overdue;

  /// No description provided for @tugasSurveiTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas Survei'**
  String get tugasSurveiTitle;

  /// No description provided for @tugasPetugasTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas Petugas'**
  String get tugasPetugasTitle;

  /// No description provided for @tugasSurveiDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Semua tugas survei lapangan yang ditugaskan akan tampil di sini.'**
  String get tugasSurveiDeskripsi;

  /// No description provided for @tugasPetugasDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memiliki tugas pada daftar ini. Muat ulang setelah admin memberikan penugasan.'**
  String get tugasPetugasDeskripsi;

  /// No description provided for @terlambatXjam.
  ///
  /// In id, this message translates to:
  /// **'Lewat {hours} jam'**
  String terlambatXjam(int hours);

  /// No description provided for @slaXjam.
  ///
  /// In id, this message translates to:
  /// **'Batas {hours} jam'**
  String slaXjam(int hours);

  /// No description provided for @slaBesok.
  ///
  /// In id, this message translates to:
  /// **'Batas besok'**
  String get slaBesok;

  /// No description provided for @slaXhari.
  ///
  /// In id, this message translates to:
  /// **'Batas {days} hari'**
  String slaXhari(int days);

  /// No description provided for @adminMemintaInfo.
  ///
  /// In id, this message translates to:
  /// **'Admin meminta informasi tambahan untuk melengkapi laporan ini.'**
  String get adminMemintaInfo;

  /// No description provided for @tenggatTanggal.
  ///
  /// In id, this message translates to:
  /// **'Tenggat {date}.'**
  String tenggatTanggal(String date);

  /// No description provided for @eventFallback.
  ///
  /// In id, this message translates to:
  /// **'Perkembangan laporan'**
  String get eventFallback;

  /// No description provided for @simpanSinkronkanNanti.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan sinkronkan nanti'**
  String get simpanSinkronkanNanti;

  /// No description provided for @kondisiBerat.
  ///
  /// In id, this message translates to:
  /// **'Berat'**
  String get kondisiBerat;

  /// No description provided for @dampakKeselamatanAkses.
  ///
  /// In id, this message translates to:
  /// **'Keselamatan · akses terganggu'**
  String get dampakKeselamatanAkses;

  /// No description provided for @exportInfoDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Export laporan dalam format CSV, GeoJSON, atau PDF. Data akan difilter sesuai opsi yang dipilih.'**
  String get exportInfoDeskripsi;

  /// No description provided for @exportCsvDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Export data laporan dalam format CSV untuk Excel atau Google Sheets.'**
  String get exportCsvDeskripsi;

  /// No description provided for @exportGeojsonDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Export data laporan dengan koordinat geospasial untuk GIS.'**
  String get exportGeojsonDeskripsi;

  /// No description provided for @exportPdfDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Export laporan lengkap dalam format PDF.'**
  String get exportPdfDeskripsi;

  /// No description provided for @exportCsvGagal.
  ///
  /// In id, this message translates to:
  /// **'Export CSV gagal:'**
  String get exportCsvGagal;

  /// No description provided for @exportGeojsonGagal.
  ///
  /// In id, this message translates to:
  /// **'Export GeoJSON gagal:'**
  String get exportGeojsonGagal;

  /// No description provided for @exportPdfGagal.
  ///
  /// In id, this message translates to:
  /// **'Export PDF gagal:'**
  String get exportPdfGagal;

  /// No description provided for @faktorKeparahan.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Keparahan (Severity)'**
  String get faktorKeparahan;

  /// No description provided for @faktorKebaruan.
  ///
  /// In id, this message translates to:
  /// **'Kebaruan Laporan (Recency)'**
  String get faktorKebaruan;

  /// No description provided for @faktorUrgensi.
  ///
  /// In id, this message translates to:
  /// **'Urgensi Kategori (Category)'**
  String get faktorUrgensi;

  /// No description provided for @faktorKepadatan.
  ///
  /// In id, this message translates to:
  /// **'Kepadatan Wilayah (Location)'**
  String get faktorKepadatan;

  /// No description provided for @faktorRiwayat.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Wilayah/Laporan (History)'**
  String get faktorRiwayat;

  /// No description provided for @totalBobotSesuai.
  ///
  /// In id, this message translates to:
  /// **'Total bobot: 100% (Sesuai)'**
  String get totalBobotSesuai;

  /// No description provided for @totalBobotDisarankan.
  ///
  /// In id, this message translates to:
  /// **'Total bobot: {total}% (Disarankan total 100%)'**
  String totalBobotDisarankan(int total);

  /// No description provided for @roleDescAdmin.
  ///
  /// In id, this message translates to:
  /// **'Kelola unit UPT, SLA, dan konfigurasi bobot prioritas.'**
  String get roleDescAdmin;

  /// No description provided for @roleDescPetugas.
  ///
  /// In id, this message translates to:
  /// **'Tindak lanjut teknis lapangan dan penyelesaian masalah pengaduan.'**
  String get roleDescPetugas;

  /// No description provided for @roleDescWarga.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan pengaduan publik dan pantau status penyelesaian.'**
  String get roleDescWarga;

  /// No description provided for @roleDescDefault.
  ///
  /// In id, this message translates to:
  /// **'Akses fitur operasional sistem SIGAP.'**
  String get roleDescDefault;

  /// No description provided for @assessmentAiMunculNanti.
  ///
  /// In id, this message translates to:
  /// **'Assessment AI akan muncul setelah laporan diajukan dan diproses.'**
  String get assessmentAiMunculNanti;

  /// No description provided for @reportLabelId.
  ///
  /// In id, this message translates to:
  /// **'Laporan: {id}'**
  String reportLabelId(String id);

  /// No description provided for @laporanCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} laporan'**
  String laporanCountLabel(int count);

  /// No description provided for @semuaLabel.
  ///
  /// In id, this message translates to:
  /// **'Semua {label}'**
  String semuaLabel(String label);

  /// No description provided for @targetJamHari.
  ///
  /// In id, this message translates to:
  /// **'Target: {hours} jam ({days} hari)'**
  String targetJamHari(int hours, double days);

  /// No description provided for @slaOverdueLaporan.
  ///
  /// In id, this message translates to:
  /// **'{count} laporan'**
  String slaOverdueLaporan(int count);

  /// No description provided for @syncChannelName.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Sinkronisasi'**
  String get syncChannelName;

  /// No description provided for @syncChannelDescription.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi untuk event sinkronisasi'**
  String get syncChannelDescription;

  /// No description provided for @itemTidakDisinkronkanPercobaan.
  ///
  /// In id, this message translates to:
  /// **'Item {key} tidak dapat disinkronkan setelah beberapa percobaan.'**
  String itemTidakDisinkronkanPercobaan(String key);

  /// No description provided for @beberapaItemTidakDisinkronkan.
  ///
  /// In id, this message translates to:
  /// **'Beberapa item tidak dapat disinkronkan setelah beberapa percobaan.'**
  String get beberapaItemTidakDisinkronkan;

  /// No description provided for @pilihWilayahFallback.
  ///
  /// In id, this message translates to:
  /// **'Pilih Wilayah'**
  String get pilihWilayahFallback;

  /// No description provided for @kabBandungFallback.
  ///
  /// In id, this message translates to:
  /// **'Kab. Bandung'**
  String get kabBandungFallback;

  /// No description provided for @draftLabelStatus.
  ///
  /// In id, this message translates to:
  /// **'Draf'**
  String get draftLabelStatus;

  /// No description provided for @digabungLabelStatus.
  ///
  /// In id, this message translates to:
  /// **'Digabung'**
  String get digabungLabelStatus;

  /// No description provided for @dipisahLabelStatus.
  ///
  /// In id, this message translates to:
  /// **'Dipisah'**
  String get dipisahLabelStatus;

  /// No description provided for @dalamReviewLabelStatus.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get dalamReviewLabelStatus;

  /// No description provided for @noAssessmentFactors.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada faktor penilaian yang tersedia.'**
  String get noAssessmentFactors;

  /// No description provided for @latitude.
  ///
  /// In id, this message translates to:
  /// **'Lintang'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In id, this message translates to:
  /// **'Bujur'**
  String get longitude;

  /// No description provided for @diperbaruiPada.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui: {time}'**
  String diperbaruiPada(Object time);

  /// No description provided for @akurasiSedang.
  ///
  /// In id, this message translates to:
  /// **'Akurasi sedang'**
  String get akurasiSedang;

  /// No description provided for @akurasiBuruk.
  ///
  /// In id, this message translates to:
  /// **'Akurasi buruk'**
  String get akurasiBuruk;

  /// No description provided for @laporanPendukungCount.
  ///
  /// In id, this message translates to:
  /// **'laporan pendukung'**
  String get laporanPendukungCount;

  /// No description provided for @statusOnline.
  ///
  /// In id, this message translates to:
  /// **'Terhubung'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In id, this message translates to:
  /// **'Tanpa koneksi'**
  String get statusOffline;

  /// No description provided for @statusSyncing.
  ///
  /// In id, this message translates to:
  /// **'Menyinkronkan'**
  String get statusSyncing;

  /// No description provided for @statusErrorLabel.
  ///
  /// In id, this message translates to:
  /// **'Kesalahan'**
  String get statusErrorLabel;

  /// No description provided for @sinkronStatusA11y.
  ///
  /// In id, this message translates to:
  /// **'Status sinkron: {status}'**
  String sinkronStatusA11y(Object status);

  /// No description provided for @bukaPusatSinkronisasiLink.
  ///
  /// In id, this message translates to:
  /// **'Buka Pusat Sinkronisasi →'**
  String get bukaPusatSinkronisasiLink;

  /// No description provided for @laporanBelumTersinkronCount.
  ///
  /// In id, this message translates to:
  /// **'{count} laporan belum tersinkron'**
  String laporanBelumTersinkronCount(Object count);

  /// No description provided for @defaultPrivatPetugas.
  ///
  /// In id, this message translates to:
  /// **'Batasi identitas akun kepada petugas berwenang'**
  String get defaultPrivatPetugas;

  /// No description provided for @severityColonValue.
  ///
  /// In id, this message translates to:
  /// **'Keparahan: {value}'**
  String severityColonValue(Object value);

  /// No description provided for @scoreColonValue.
  ///
  /// In id, this message translates to:
  /// **'Skor: {value}'**
  String scoreColonValue(Object value);

  /// No description provided for @ringkasanLaporanUppercase.
  ///
  /// In id, this message translates to:
  /// **'RINGKASAN LAPORAN'**
  String get ringkasanLaporanUppercase;

  /// No description provided for @waktuLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get waktuLabel;

  /// No description provided for @dampakLabel.
  ///
  /// In id, this message translates to:
  /// **'Dampak'**
  String get dampakLabel;

  /// No description provided for @fotoIndexPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'foto {index}'**
  String fotoIndexPlaceholder(Object index);

  /// No description provided for @checklistWajib.
  ///
  /// In id, this message translates to:
  /// **'DAFTAR PEMERIKSAAN WAJIB'**
  String get checklistWajib;

  /// No description provided for @kasusSerupaDitemukan.
  ///
  /// In id, this message translates to:
  /// **'{count} kasus serupa ditemukan di dekat sini'**
  String kasusSerupaDitemukan(Object count);

  /// No description provided for @kemiripanLabel.
  ///
  /// In id, this message translates to:
  /// **'kemiripan'**
  String get kemiripanLabel;

  /// No description provided for @naLabel.
  ///
  /// In id, this message translates to:
  /// **'Tidak tersedia'**
  String get naLabel;

  /// No description provided for @lessThan1dLabel.
  ///
  /// In id, this message translates to:
  /// **'<1 hari'**
  String get lessThan1dLabel;

  /// No description provided for @sayaMenyatakanBenar.
  ///
  /// In id, this message translates to:
  /// **'Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat.'**
  String get sayaMenyatakanBenar;

  /// No description provided for @terimaTugasLabel.
  ///
  /// In id, this message translates to:
  /// **'Terima Tugas'**
  String get terimaTugasLabel;

  /// No description provided for @labelSubmitted.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi'**
  String get labelSubmitted;

  /// No description provided for @labelUnderReview.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get labelUnderReview;

  /// No description provided for @labelDiproses.
  ///
  /// In id, this message translates to:
  /// **'Diproses'**
  String get labelDiproses;

  /// No description provided for @labelTerverifikasi.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi'**
  String get labelTerverifikasi;

  /// No description provided for @labelSelesai.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get labelSelesai;

  /// No description provided for @labelDitolak.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get labelDitolak;

  /// No description provided for @labelBaru.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get labelBaru;

  /// No description provided for @labelDitugaskan.
  ///
  /// In id, this message translates to:
  /// **'Ditugaskan'**
  String get labelDitugaskan;

  /// No description provided for @labelDikerjakan.
  ///
  /// In id, this message translates to:
  /// **'Dikerjakan'**
  String get labelDikerjakan;

  /// No description provided for @reportPhotoPreparationFailed.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat menyiapkan foto ini. Pilih JPG, PNG, atau WebP dengan ukuran asli maksimal 10 MB.'**
  String get reportPhotoPreparationFailed;

  /// No description provided for @taskAcceptStart.
  ///
  /// In id, this message translates to:
  /// **'Terima dan mulai survei'**
  String get taskAcceptStart;

  /// No description provided for @taskAwaitingReview.
  ///
  /// In id, this message translates to:
  /// **'Petugas sudah mengirim hasil pekerjaan. Tunggu pemeriksaan admin; pengiriman ini belum menutup laporan warga.'**
  String get taskAwaitingReview;

  /// No description provided for @taskChecklistMissing.
  ///
  /// In id, this message translates to:
  /// **'Admin belum menyiapkan daftar pemeriksaan kategori ini. Minta admin melengkapinya sebelum Anda mengirim hasil survei.'**
  String get taskChecklistMissing;

  /// No description provided for @taskCitizenEvidence.
  ///
  /// In id, this message translates to:
  /// **'Foto warga'**
  String get taskCitizenEvidence;

  /// No description provided for @taskContinueSurvey.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan survei'**
  String get taskContinueSurvey;

  /// No description provided for @taskDepth.
  ///
  /// In id, this message translates to:
  /// **'Kedalaman'**
  String get taskDepth;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail tugas'**
  String get taskDetailsTitle;

  /// No description provided for @taskFindings.
  ///
  /// In id, this message translates to:
  /// **'Kondisi yang ditemukan'**
  String get taskFindings;

  /// No description provided for @taskHeight.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get taskHeight;

  /// No description provided for @taskInstructions.
  ///
  /// In id, this message translates to:
  /// **'Baca petunjuk lapangan'**
  String get taskInstructions;

  /// No description provided for @taskInstructionsMissing.
  ///
  /// In id, this message translates to:
  /// **'Tugas ini belum memuat petunjuk lapangan. Minta penjelasan sebelum menentukan pekerjaan yang perlu Anda lakukan.'**
  String get taskInstructionsMissing;

  /// No description provided for @taskLength.
  ///
  /// In id, this message translates to:
  /// **'Panjang'**
  String get taskLength;

  /// No description provided for @taskMeasurements.
  ///
  /// In id, this message translates to:
  /// **'Ukuran yang dicatat'**
  String get taskMeasurements;

  /// No description provided for @taskNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan petugas'**
  String get taskNotes;

  /// No description provided for @taskPhotosLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat membuka foto pelapor. Periksa koneksi, lalu muat kembali foto.'**
  String get taskPhotosLoadFailed;

  /// No description provided for @taskRecommendation.
  ///
  /// In id, this message translates to:
  /// **'Saran tindak lanjut'**
  String get taskRecommendation;

  /// No description provided for @taskRequiredChecklist.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan wajib'**
  String get taskRequiredChecklist;

  /// No description provided for @taskResolved.
  ///
  /// In id, this message translates to:
  /// **'Admin telah menyetujui hasil pekerjaan dan menutup penanganan laporan ini.'**
  String get taskResolved;

  /// No description provided for @taskSavedPhotosOnline.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan data tugas di perangkat ini. Sambungkan internet untuk membuka foto yang belum dimuat.'**
  String get taskSavedPhotosOnline;

  /// No description provided for @taskSavePreparation.
  ///
  /// In id, this message translates to:
  /// **'Simpan data tugas sebelum berangkat agar Anda dapat membaca petunjuk tanpa internet.'**
  String get taskSavePreparation;

  /// No description provided for @taskSurveyPhotos.
  ///
  /// In id, this message translates to:
  /// **'Foto survei'**
  String get taskSurveyPhotos;

  /// No description provided for @taskSurveyResults.
  ///
  /// In id, this message translates to:
  /// **'Tinjau hasil survei'**
  String get taskSurveyResults;

  /// No description provided for @taskWidth.
  ///
  /// In id, this message translates to:
  /// **'Lebar'**
  String get taskWidth;

  /// No description provided for @taskPhotoCount.
  ///
  /// In id, this message translates to:
  /// **'{count} foto'**
  String taskPhotoCount(int count);

  /// No description provided for @mobileNotSaved.
  ///
  /// In id, this message translates to:
  /// **'Belum disimpan'**
  String get mobileNotSaved;

  /// No description provided for @mobileSaveThisTaskToPrepareForTheSurvey.
  ///
  /// In id, this message translates to:
  /// **'Simpan tugas sebelum Anda berangkat ke lokasi.'**
  String get mobileSaveThisTaskToPrepareForTheSurvey;

  /// No description provided for @mobileAcceptStartSurvey.
  ///
  /// In id, this message translates to:
  /// **'Terima dan mulai survei'**
  String get mobileAcceptStartSurvey;

  /// No description provided for @mobileNoInternetAccess.
  ///
  /// In id, this message translates to:
  /// **'Perangkat belum terhubung'**
  String get mobileNoInternetAccess;

  /// No description provided for @mobileInternetConnected.
  ///
  /// In id, this message translates to:
  /// **'Perangkat terhubung ke internet'**
  String get mobileInternetConnected;

  /// No description provided for @mobileCheckingConnection.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa koneksi'**
  String get mobileCheckingConnection;

  /// No description provided for @mobileConnectTheDeviceToTheInternetBeforeSyncing.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan perangkat ke internet sebelum sinkronisasi.'**
  String get mobileConnectTheDeviceToTheInternetBeforeSyncing;

  /// No description provided for @mobileQueuedItemsRemainSavedUntilInternetAccessReturns.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan antrean pada perangkat ini. Hubungkan internet, lalu kirim dan periksa hasilnya di sini.'**
  String get mobileQueuedItemsRemainSavedUntilInternetAccessReturns;

  /// No description provided for @mobileTaskLocationsForAuthorizedFieldWorkers.
  ///
  /// In id, this message translates to:
  /// **'Gunakan titik tugas untuk menyiapkan kunjungan. Cocokkan titik dengan alamat dan petunjuk lapangan sebelum berangkat.'**
  String get mobileTaskLocationsForAuthorizedFieldWorkers;

  /// No description provided for @mobileTapAMarkerToSeeTheTaskSummary.
  ///
  /// In id, this message translates to:
  /// **'Ketuk titik untuk melihat ringkasan tugas.'**
  String get mobileTapAMarkerToSeeTheTaskSummary;

  /// No description provided for @mobileTaskLocations.
  ///
  /// In id, this message translates to:
  /// **'Sebaran lokasi tugas'**
  String get mobileTaskLocations;

  /// No description provided for @mobileOfficeAddressOptional.
  ///
  /// In id, this message translates to:
  /// **'Alamat Kantor (opsional)'**
  String get mobileOfficeAddressOptional;

  /// No description provided for @mobileContactPhoneOptional.
  ///
  /// In id, this message translates to:
  /// **'Kontak / Telepon (opsional)'**
  String get mobileContactPhoneOptional;

  /// No description provided for @mobileEditWorkUnit.
  ///
  /// In id, this message translates to:
  /// **'Edit Unit Kerja'**
  String get mobileEditWorkUnit;

  /// No description provided for @mobileChooseTheUnitThatWillHandleThisCase.
  ///
  /// In id, this message translates to:
  /// **'Pilih unit yang akan menangani kasus ini.'**
  String get mobileChooseTheUnitThatWillHandleThisCase;

  /// No description provided for @mobileNoActiveUnits.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada unit aktif.'**
  String get mobileNoActiveUnits;

  /// No description provided for @mobileDepartmentsUnits.
  ///
  /// In id, this message translates to:
  /// **'SKPD & Unit'**
  String get mobileDepartmentsUnits;

  /// No description provided for @mobileArea.
  ///
  /// In id, this message translates to:
  /// **'Wilayah'**
  String get mobileArea;

  /// No description provided for @mobileChangeCaseStatus.
  ///
  /// In id, this message translates to:
  /// **'Ubah status kasus'**
  String get mobileChangeCaseStatus;

  /// No description provided for @mobilePrimaryReportUUID.
  ///
  /// In id, this message translates to:
  /// **'UUID laporan primer'**
  String get mobilePrimaryReportUUID;

  /// No description provided for @mobileReceivingUnitUUID.
  ///
  /// In id, this message translates to:
  /// **'UUID unit penerima'**
  String get mobileReceivingUnitUUID;

  /// No description provided for @mobileReceivingUnitOptional.
  ///
  /// In id, this message translates to:
  /// **'Unit penerima (opsional)'**
  String get mobileReceivingUnitOptional;

  /// No description provided for @mobileReportsMergedSuccessfully.
  ///
  /// In id, this message translates to:
  /// **'Laporan berhasil digabungkan'**
  String get mobileReportsMergedSuccessfully;

  /// No description provided for @mobileNoDuplicatesFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada duplikat ditemukan'**
  String get mobileNoDuplicatesFound;

  /// No description provided for @mobileCompareDuplicateCandidates.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan kandidat duplikat'**
  String get mobileCompareDuplicateCandidates;

  /// No description provided for @mobilePhotoUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Foto tidak tersedia'**
  String get mobilePhotoUnavailable;

  /// No description provided for @mobileLocationUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Lokasi belum tersedia'**
  String get mobileLocationUnavailable;

  /// No description provided for @mobileAssignSurveyTask.
  ///
  /// In id, this message translates to:
  /// **'Kirim Tugas Survei'**
  String get mobileAssignSurveyTask;

  /// No description provided for @mobileOpenCaseDetails.
  ///
  /// In id, this message translates to:
  /// **'Buka detail kasus ↗'**
  String get mobileOpenCaseDetails;

  /// No description provided for @mobileEnableLocationToViewTheMap.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan lokasi untuk melihat peta'**
  String get mobileEnableLocationToViewTheMap;

  /// No description provided for @mobileCaseStatus.
  ///
  /// In id, this message translates to:
  /// **'Status kasus'**
  String get mobileCaseStatus;

  /// No description provided for @mobileVerifiedCompleted.
  ///
  /// In id, this message translates to:
  /// **'Terverifikasi / selesai'**
  String get mobileVerifiedCompleted;

  /// No description provided for @mobileAwaitingFollowUp.
  ///
  /// In id, this message translates to:
  /// **'Menunggu tindak lanjut'**
  String get mobileAwaitingFollowUp;

  /// No description provided for @mobileInProgress.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditangani'**
  String get mobileInProgress;

  /// No description provided for @mobileLocationsAreGeneralizedToProtectReporterPrivacyPDPLaw.
  ///
  /// In id, this message translates to:
  /// **'Peta publik menampilkan perkiraan lokasi untuk membatasi penyebaran koordinat rinci pelapor.'**
  String get mobileLocationsAreGeneralizedToProtectReporterPrivacyPDPLaw;

  /// No description provided for @mobileAppearanceLanguage.
  ///
  /// In id, this message translates to:
  /// **'Tampilan & bahasa'**
  String get mobileAppearanceLanguage;

  /// No description provided for @mobileTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get mobileTheme;

  /// No description provided for @mobileSystemDefault.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get mobileSystemDefault;

  /// No description provided for @mobileDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get mobileDark;

  /// No description provided for @mobileLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get mobileLight;

  /// No description provided for @mobileLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get mobileLanguage;

  /// No description provided for @mobileActiveAreaDeviceLocation.
  ///
  /// In id, this message translates to:
  /// **'Wilayah aktif · lokasi perangkat'**
  String get mobileActiveAreaDeviceLocation;

  /// No description provided for @mobileABetterVillageStartsWithOurCare.
  ///
  /// In id, this message translates to:
  /// **'Bantu perbaiki desa\ndengan melaporkan kondisi di sekitar Anda.'**
  String get mobileABetterVillageStartsWithOurCare;

  /// No description provided for @mobilePhotoLocationAndFieldConditions.
  ///
  /// In id, this message translates to:
  /// **'Foto, lokasi, dan kondisi lapangan'**
  String get mobilePhotoLocationAndFieldConditions;

  /// No description provided for @mobileSafeOnThisDeviceSendWhenConnected.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan kiriman tertunda di perangkat ini. Periksa pengirimannya saat internet tersedia.'**
  String get mobileSafeOnThisDeviceSendWhenConnected;

  /// No description provided for @mobileAllReportsSynced.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada laporan yang menunggu pengiriman di perangkat ini.'**
  String get mobileAllReportsSynced;

  /// No description provided for @mobileSyncStatusIsUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Status sinkronisasi belum tersedia.'**
  String get mobileSyncStatusIsUnavailable;

  /// No description provided for @mobileMyReports.
  ///
  /// In id, this message translates to:
  /// **'Laporan saya'**
  String get mobileMyReports;

  /// No description provided for @mobileViewAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua →'**
  String get mobileViewAll;

  /// No description provided for @mobileReloadReportSummary.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang ringkasan laporan'**
  String get mobileReloadReportSummary;

  /// No description provided for @mobileCasesNearYou.
  ///
  /// In id, this message translates to:
  /// **'Kasus di sekitar Anda'**
  String get mobileCasesNearYou;

  /// No description provided for @mobileOpenMap.
  ///
  /// In id, this message translates to:
  /// **'Buka peta ↗'**
  String get mobileOpenMap;

  /// No description provided for @mobileAllowDeviceLocationToSeeNearbyCases.
  ///
  /// In id, this message translates to:
  /// **'Izinkan lokasi perangkat untuk melihat kasus di sekitar Anda.'**
  String get mobileAllowDeviceLocationToSeeNearbyCases;

  /// No description provided for @mobileNoNearbyCasesYet.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum menemukan laporan pada jangkauan ini. Geser peta atau muat ulang untuk melihat lokasi lain.'**
  String get mobileNoNearbyCasesYet;

  /// No description provided for @mobileReloadNearbyCases.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang kasus sekitar'**
  String get mobileReloadNearbyCases;

  /// No description provided for @mobileYourIdentityIsSafePublicReportsDoNotShow.
  ///
  /// In id, this message translates to:
  /// **'Portal publik tidak menampilkan identitas akun pelapor. Hindari menulis data pribadi di uraian atau foto.'**
  String get mobileYourIdentityIsSafePublicReportsDoNotShow;

  /// No description provided for @mobileFacilityReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan fasilitas'**
  String get mobileFacilityReport;

  /// No description provided for @mobileQueued.
  ///
  /// In id, this message translates to:
  /// **'Belum terkirim'**
  String get mobileQueued;

  /// No description provided for @mobileNoReportsInThisCategoryYet.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada laporan yang cocok dengan pilihan ini. Ubah filter atau buat laporan jika Anda menemukan masalah baru.'**
  String get mobileNoReportsInThisCategoryYet;

  /// No description provided for @mobileCreateNewReport.
  ///
  /// In id, this message translates to:
  /// **'+ Buat laporan baru'**
  String get mobileCreateNewReport;

  /// No description provided for @mobileViewProgress.
  ///
  /// In id, this message translates to:
  /// **'Lihat perkembangan →'**
  String get mobileViewProgress;

  /// No description provided for @mobileAccountDevice.
  ///
  /// In id, this message translates to:
  /// **'Akun & perangkat'**
  String get mobileAccountDevice;

  /// No description provided for @mobileUserContext.
  ///
  /// In id, this message translates to:
  /// **'Akun yang Anda gunakan'**
  String get mobileUserContext;

  /// No description provided for @mobileResident.
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get mobileResident;

  /// No description provided for @mobileSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Petugas lapangan'**
  String get mobileSurveyor;

  /// No description provided for @mobileAdministrator.
  ///
  /// In id, this message translates to:
  /// **'Administrator'**
  String get mobileAdministrator;

  /// No description provided for @mobileUser.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get mobileUser;

  /// No description provided for @mobileAuthenticatedAccount.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah masuk'**
  String get mobileAuthenticatedAccount;

  /// No description provided for @mobileConnectionStatus.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi perangkat'**
  String get mobileConnectionStatus;

  /// No description provided for @mobileSaveReportsOnThisDeviceWhileDisconnected.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat menyimpan laporan saat internet terputus. Periksa pusat sinkronisasi setelah koneksi pulih.'**
  String get mobileSaveReportsOnThisDeviceWhileDisconnected;

  /// No description provided for @mobileSignOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari akun'**
  String get mobileSignOut;

  /// No description provided for @mobileSyncCenter.
  ///
  /// In id, this message translates to:
  /// **'Pusat sinkronisasi'**
  String get mobileSyncCenter;

  /// No description provided for @mobileAnInternetConnectionIsRequiredToSendAdditionalEvidence.
  ///
  /// In id, this message translates to:
  /// **'Koneksi internet diperlukan untuk mengirim bukti tambahan.'**
  String get mobileAnInternetConnectionIsRequiredToSendAdditionalEvidence;

  /// No description provided for @mobileYouAreOffline.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan perangkat ke internet'**
  String get mobileYouAreOffline;

  /// No description provided for @mobileReadyToSyncData.
  ///
  /// In id, this message translates to:
  /// **'Kirim antrean saat Anda siap'**
  String get mobileReadyToSyncData;

  /// No description provided for @mobileSendReportsAndSurveyResultsToTheOperatorWorkspace.
  ///
  /// In id, this message translates to:
  /// **'Kirim antrean agar petugas dapat membaca laporan dan hasil survei. Periksa hasil pengiriman sebelum meninggalkan halaman.'**
  String get mobileSendReportsAndSurveyResultsToTheOperatorWorkspace;

  /// No description provided for @mobileNoPendingSubmissionsAllDataOnThisDeviceIs.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kiriman tertunda dalam antrean perangkat ini. Draf yang belum Anda kirim tidak termasuk antrean.'**
  String get mobileNoPendingSubmissionsAllDataOnThisDeviceIs;

  /// No description provided for @mobileSurveyResult.
  ///
  /// In id, this message translates to:
  /// **'Hasil survei'**
  String get mobileSurveyResult;

  /// No description provided for @mobileResidentReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan warga'**
  String get mobileResidentReport;

  /// No description provided for @mobilePending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get mobilePending;

  /// No description provided for @mobileRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get mobileRetry;

  /// No description provided for @mobileSyncing.
  ///
  /// In id, this message translates to:
  /// **'Menyinkronkan…'**
  String get mobileSyncing;

  /// No description provided for @mobileTheQueueIsStoredOnThisDevice.
  ///
  /// In id, this message translates to:
  /// **'Daftar ini hanya menunjukkan antrean pada perangkat ini. Buka rincian laporan untuk memeriksa kiriman yang sudah masuk.'**
  String get mobileTheQueueIsStoredOnThisDevice;

  /// No description provided for @mobileSomeSubmissionsAreStillPendingYourDataRemainsSafe.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum mengirim sebagian antrean. Periksa kiriman yang perlu Anda coba kembali; jangan hapus data sebelum memastikan pengiriman.'**
  String get mobileSomeSubmissionsAreStillPendingYourDataRemainsSafe;

  /// No description provided for @mobileReportDetails.
  ///
  /// In id, this message translates to:
  /// **'Detail laporan'**
  String get mobileReportDetails;

  /// No description provided for @mobileYourReportHelpsStaffUnderstandFacilityConditions.
  ///
  /// In id, this message translates to:
  /// **'Laporan Anda membantu petugas memahami kondisi fasilitas.'**
  String get mobileYourReportHelpsStaffUnderstandFacilityConditions;

  /// No description provided for @mobileRELATEDCASE.
  ///
  /// In id, this message translates to:
  /// **'KASUS TERKAIT'**
  String get mobileRELATEDCASE;

  /// No description provided for @mobileViewRelatedCase.
  ///
  /// In id, this message translates to:
  /// **'Lihat kasus terkait →'**
  String get mobileViewRelatedCase;

  /// No description provided for @mobileReportProgress.
  ///
  /// In id, this message translates to:
  /// **'Perkembangan laporan'**
  String get mobileReportProgress;

  /// No description provided for @mobileNoReportUpdatesYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan perkembangan untuk laporan ini. Muat ulang nanti untuk memeriksa pembaruan.'**
  String get mobileNoReportUpdatesYet;

  /// No description provided for @mobileReloadProgress.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang perkembangan'**
  String get mobileReloadProgress;

  /// No description provided for @mobileOnlyAuthorizedStaffCanAccessReporterDetails.
  ///
  /// In id, this message translates to:
  /// **'Petugas berwenang dapat membuka detail pelapor untuk menindaklanjuti laporan. Portal publik tidak menampilkan identitas akun Anda.'**
  String get mobileOnlyAuthorizedStaffCanAccessReporterDetails;

  /// No description provided for @mobileReloadReport.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang laporan'**
  String get mobileReloadReport;

  /// No description provided for @mobileAwaitingSync.
  ///
  /// In id, this message translates to:
  /// **'Menunggu sinkronisasi'**
  String get mobileAwaitingSync;

  /// No description provided for @mobileYourReportIsSafeOnThisDeviceOpenSync.
  ///
  /// In id, this message translates to:
  /// **'SIGAP baru menyimpan laporan di perangkat ini; petugas belum menerimanya. Buka pusat sinkronisasi saat internet tersedia.'**
  String get mobileYourReportIsSafeOnThisDeviceOpenSync;

  /// No description provided for @mobileAwaitingReportSubmission.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pengiriman laporan'**
  String get mobileAwaitingReportSubmission;

  /// No description provided for @mobileNoCaseIDAssignedYet.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan terlebih dahulu agar SIGAP dapat memberikan nomor laporan.'**
  String get mobileNoCaseIDAssignedYet;

  /// No description provided for @mobileSavedOnDevice.
  ///
  /// In id, this message translates to:
  /// **'Disimpan di perangkat'**
  String get mobileSavedOnDevice;

  /// No description provided for @mobileWaitingForAConnectionToSendTheReport.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan internet dan buka pusat sinkronisasi untuk mengirim laporan ini.'**
  String get mobileWaitingForAConnectionToSendTheReport;

  /// No description provided for @mobileAdditionalEvidenceSent.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah menambahkan bukti ke laporan ini.'**
  String get mobileAdditionalEvidenceSent;

  /// No description provided for @mobileStaffRequestedAnotherPhoto.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi bukti yang petugas minta'**
  String get mobileStaffRequestedAnotherPhoto;

  /// No description provided for @mobileNewPhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto baru'**
  String get mobileNewPhoto;

  /// No description provided for @mobileChoosePhotoFromDevice.
  ///
  /// In id, this message translates to:
  /// **'Pilih foto dari perangkat'**
  String get mobileChoosePhotoFromDevice;

  /// No description provided for @mobileSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim…'**
  String get mobileSending;

  /// No description provided for @mobileSendAdditionalEvidence.
  ///
  /// In id, this message translates to:
  /// **'Kirim bukti tambahan'**
  String get mobileSendAdditionalEvidence;

  /// No description provided for @mobileReportSuccessfullySentToStaff.
  ///
  /// In id, this message translates to:
  /// **'SIGAP telah menerima laporan Anda. Buka detail laporan untuk mengikuti pemeriksaan dan tindak lanjutnya.'**
  String get mobileReportSuccessfullySentToStaff;

  /// No description provided for @mobilePhotoEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti foto'**
  String get mobilePhotoEvidence;

  /// No description provided for @mobileCondition.
  ///
  /// In id, this message translates to:
  /// **'Kondisi'**
  String get mobileCondition;

  /// No description provided for @mobileReview.
  ///
  /// In id, this message translates to:
  /// **'Periksa'**
  String get mobileReview;

  /// No description provided for @mobileBack.
  ///
  /// In id, this message translates to:
  /// **'← Kembali'**
  String get mobileBack;

  /// No description provided for @mobileSendReport.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan'**
  String get mobileSendReport;

  /// No description provided for @mobileContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan →'**
  String get mobileContinue;

  /// No description provided for @mobileWhatWouldYouLikeToReport.
  ///
  /// In id, this message translates to:
  /// **'Apa yang ingin Anda laporkan?'**
  String get mobileWhatWouldYouLikeToReport;

  /// No description provided for @mobileChooseTheTypeOfDamagedFacility.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis fasilitas yang mengalami kerusakan.'**
  String get mobileChooseTheTypeOfDamagedFacility;

  /// No description provided for @mobileReportTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul laporan'**
  String get mobileReportTitle;

  /// No description provided for @mobileExamplePotholeNearTheMarket.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Jalan berlubang dekat pasar'**
  String get mobileExamplePotholeNearTheMarket;

  /// No description provided for @mobileShowTheConditionsOnSite.
  ///
  /// In id, this message translates to:
  /// **'Tunjukkan kondisi di lapangan'**
  String get mobileShowTheConditionsOnSite;

  /// No description provided for @mobileTakeAClearPhotoWithoutFacesOrPersonalDetails.
  ///
  /// In id, this message translates to:
  /// **'Tunjukkan fasilitas dan kerusakan dengan jelas. Hindari wajah, nomor kendaraan, atau dokumen pribadi yang tidak perlu.'**
  String get mobileTakeAClearPhotoWithoutFacesOrPersonalDetails;

  /// No description provided for @mobileUPLOADEDEVIDENCE.
  ///
  /// In id, this message translates to:
  /// **'BUKTI UNGGAHAN'**
  String get mobileUPLOADEDEVIDENCE;

  /// No description provided for @mobileNoPhotoYet.
  ///
  /// In id, this message translates to:
  /// **'Anda belum memilih foto'**
  String get mobileNoPhotoYet;

  /// No description provided for @mobileTakeOrChooseAPhotoFromYourDevice.
  ///
  /// In id, this message translates to:
  /// **'Ambil atau pilih foto dari perangkat Anda'**
  String get mobileTakeOrChooseAPhotoFromYourDevice;

  /// No description provided for @mobilePNGJPGWebPMax1MB.
  ///
  /// In id, this message translates to:
  /// **'Pilih JPG, PNG, atau WebP. Foto asli tidak boleh melebihi 10 MB.'**
  String get mobilePNGJPGWebPMax1MB;

  /// No description provided for @mobileReplacePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get mobileReplacePhoto;

  /// No description provided for @mobileRemovePhoto.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get mobileRemovePhoto;

  /// No description provided for @mobileWhereIsItLocated.
  ///
  /// In id, this message translates to:
  /// **'Di mana lokasinya?'**
  String get mobileWhereIsItLocated;

  /// No description provided for @mobileChooseAVillageAndTheFacilityLocationOnThe.
  ///
  /// In id, this message translates to:
  /// **'Pilih desa dan titik lokasi fasilitas pada peta.'**
  String get mobileChooseAVillageAndTheFacilityLocationOnThe;

  /// No description provided for @mobileVillage.
  ///
  /// In id, this message translates to:
  /// **'Desa'**
  String get mobileVillage;

  /// No description provided for @mobileTapTheMapToMoveThePinPublicCoordinates.
  ///
  /// In id, this message translates to:
  /// **'Ketuk peta untuk memindahkan titik. Portal publik menampilkan perkiraan lokasi, bukan koordinat rinci laporan.'**
  String get mobileTapTheMapToMoveThePinPublicCoordinates;

  /// No description provided for @mobileDescribeTheConditionsYouSee.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan kondisi yang Anda lihat'**
  String get mobileDescribeTheConditionsYouSee;

  /// No description provided for @mobileDetailsHelpStaffPrioritizeRepairs.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan bagian yang rusak dan dampaknya. Petugas memakai uraian ini bersama foto untuk menentukan pemeriksaan berikutnya.'**
  String get mobileDetailsHelpStaffPrioritizeRepairs;

  /// No description provided for @mobileDamageLevel.
  ///
  /// In id, this message translates to:
  /// **'Tingkat kerusakan'**
  String get mobileDamageLevel;

  /// No description provided for @mobileDescriptionImpact.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi & dampak'**
  String get mobileDescriptionImpact;

  /// No description provided for @mobileDescribeTheDamageSizeRisksAndAffectedResidents.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan ukuran kerusakan, risiko, dan warga yang terdampak…'**
  String get mobileDescribeTheDamageSizeRisksAndAffectedResidents;

  /// No description provided for @mobileDescribeWhatYouObservedDoNotIncludeNamesPhone.
  ///
  /// In id, this message translates to:
  /// **'Sampaikan kondisi sesuai pengamatan. Hindari mencantumkan nama, nomor telepon, atau data pribadi.'**
  String get mobileDescribeWhatYouObservedDoNotIncludeNamesPhone;

  /// No description provided for @mobileASimilarCaseWasFoundNearThisLocation.
  ///
  /// In id, this message translates to:
  /// **'Lihat laporan sekitar sebelum menambahkan bukti. Lokasi yang berdekatan belum memastikan masalahnya sama.'**
  String get mobileASimilarCaseWasFoundNearThisLocation;

  /// No description provided for @mobileAddEvidence.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan bukti'**
  String get mobileAddEvidence;

  /// No description provided for @mobileCreateSeparately.
  ///
  /// In id, this message translates to:
  /// **'Buat terpisah'**
  String get mobileCreateSeparately;

  /// No description provided for @mobileMinor.
  ///
  /// In id, this message translates to:
  /// **'Ringan'**
  String get mobileMinor;

  /// No description provided for @mobileSevere.
  ///
  /// In id, this message translates to:
  /// **'Berat'**
  String get mobileSevere;

  /// No description provided for @mobileCoordinates.
  ///
  /// In id, this message translates to:
  /// **'Koordinat'**
  String get mobileCoordinates;

  /// No description provided for @mobileSurveyHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat survei'**
  String get mobileSurveyHistory;

  /// No description provided for @mobileTodaySTasks.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini'**
  String get mobileTodaySTasks;

  /// No description provided for @mobileRunAIAnalysis.
  ///
  /// In id, this message translates to:
  /// **'Jalankan analisis AI'**
  String get mobileRunAIAnalysis;

  /// No description provided for @mobileAnalysisInProgress.
  ///
  /// In id, this message translates to:
  /// **'Analisis sedang berjalan…'**
  String get mobileAnalysisInProgress;

  /// No description provided for @mobileAnalysisCompleted.
  ///
  /// In id, this message translates to:
  /// **'Analisis selesai'**
  String get mobileAnalysisCompleted;

  /// No description provided for @mobileAIPreVerificationConsolidationQueue.
  ///
  /// In id, this message translates to:
  /// **'Antrean Pra-Verifikasi AI & Konsolidasi'**
  String get mobileAIPreVerificationConsolidationQueue;

  /// No description provided for @mobileMetadataChecksPhotoValidationAndGroupingOfNearbyReports.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan metadata, validasi foto, dan pengelompokan laporan dalam radius 50–100 meter.'**
  String get mobileMetadataChecksPhotoValidationAndGroupingOfNearbyReports;

  /// No description provided for @mobileRunAIAnalysisUsingTheButtonTheVerifierMakes.
  ///
  /// In id, this message translates to:
  /// **'✧ Analisis AI dijalankan melalui tombol. Keputusan akhir berada pada verifikator.'**
  String get mobileRunAIAnalysisUsingTheButtonTheVerifierMakes;

  /// No description provided for @mobileHumanVerificationRequired.
  ///
  /// In id, this message translates to:
  /// **'Perlu Verifikasi Manusia'**
  String get mobileHumanVerificationRequired;

  /// No description provided for @mobilePossibleDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Terindikasi Duplikat'**
  String get mobilePossibleDuplicate;

  /// No description provided for @mobileLowMediaQuality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas Media Rendah'**
  String get mobileLowMediaQuality;

  /// No description provided for @mobileAICompleted.
  ///
  /// In id, this message translates to:
  /// **'AI selesai'**
  String get mobileAICompleted;

  /// No description provided for @mobileEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti'**
  String get mobileEvidence;

  /// No description provided for @mobileIdentityConcealed.
  ///
  /// In id, this message translates to:
  /// **'identitas disamarkan'**
  String get mobileIdentityConcealed;

  /// No description provided for @mobileNotAnalyzed.
  ///
  /// In id, this message translates to:
  /// **'Belum dianalisis'**
  String get mobileNotAnalyzed;

  /// No description provided for @mobileUnableToAssess.
  ///
  /// In id, this message translates to:
  /// **'Belum dapat dinilai'**
  String get mobileUnableToAssess;

  /// No description provided for @mobileIdentifiedDamage.
  ///
  /// In id, this message translates to:
  /// **'Kerusakan teridentifikasi'**
  String get mobileIdentifiedDamage;

  /// No description provided for @mobileReportsPointToTheSameObject.
  ///
  /// In id, this message translates to:
  /// **'laporan mengarah pada objek yang sama'**
  String get mobileReportsPointToTheSameObject;

  /// No description provided for @mobileApproveAsNewCase.
  ///
  /// In id, this message translates to:
  /// **'Setujui Sebagai Kasus Baru'**
  String get mobileApproveAsNewCase;

  /// No description provided for @mobileMergeIntoExistingCase.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan ke kasus yang sudah ada'**
  String get mobileMergeIntoExistingCase;

  /// No description provided for @mobileAssignFieldSurvey.
  ///
  /// In id, this message translates to:
  /// **'Kirim Tugas Survei Lapangan'**
  String get mobileAssignFieldSurvey;

  /// No description provided for @mobileRequestMorePhotos.
  ///
  /// In id, this message translates to:
  /// **'Minta Foto Tambahan'**
  String get mobileRequestMorePhotos;

  /// No description provided for @mobileRejectReport.
  ///
  /// In id, this message translates to:
  /// **'Tolak Laporan'**
  String get mobileRejectReport;

  /// No description provided for @mobileDetails.
  ///
  /// In id, this message translates to:
  /// **'Detail ↗'**
  String get mobileDetails;

  /// No description provided for @mobileDecisionReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan keputusan'**
  String get mobileDecisionReason;

  /// No description provided for @mobileNoReportsInThisQueue.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada laporan dalam antrean ini.'**
  String get mobileNoReportsInThisQueue;

  /// No description provided for @mobileMoreInformationNeeded.
  ///
  /// In id, this message translates to:
  /// **'Perlu Kelengkapan'**
  String get mobileMoreInformationNeeded;

  /// No description provided for @mobileQuickSurveyNeeded.
  ///
  /// In id, this message translates to:
  /// **'Perlu Survei Cepat'**
  String get mobileQuickSurveyNeeded;

  /// No description provided for @mobileAwaitingVerification.
  ///
  /// In id, this message translates to:
  /// **'Menunggu verifikasi'**
  String get mobileAwaitingVerification;

  /// No description provided for @mobileWhatNeedsAttentionToday.
  ///
  /// In id, this message translates to:
  /// **'Apa yang harus ditangani hari ini?'**
  String get mobileWhatNeedsAttentionToday;

  /// No description provided for @mobileCurrentInfrastructureConditionsAndFollowUpActions.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan kondisi infrastruktur dan tindak lanjut terkini.'**
  String get mobileCurrentInfrastructureConditionsAndFollowUpActions;

  /// No description provided for @mobileOverdueSLA.
  ///
  /// In id, this message translates to:
  /// **'SLA terlewat'**
  String get mobileOverdueSLA;

  /// No description provided for @mobileNeedsInformation.
  ///
  /// In id, this message translates to:
  /// **'Perlu kelengkapan'**
  String get mobileNeedsInformation;

  /// No description provided for @mobileViewRelatedCases.
  ///
  /// In id, this message translates to:
  /// **'Lihat kasus terkait ↗'**
  String get mobileViewRelatedCases;

  /// No description provided for @mobileReportsReceivedAndCompletedLast30Days.
  ///
  /// In id, this message translates to:
  /// **'Arus laporan dan penyelesaian · 30 hari terakhir'**
  String get mobileReportsReceivedAndCompletedLast30Days;

  /// No description provided for @mobileCasesInYourArea.
  ///
  /// In id, this message translates to:
  /// **'Sebaran kasus di wilayah Anda'**
  String get mobileCasesInYourArea;

  /// No description provided for @mobileOpenFullMapCases.
  ///
  /// In id, this message translates to:
  /// **'Buka Peta & Kasus Penuh ↗'**
  String get mobileOpenFullMapCases;

  /// No description provided for @mobileCasesRequiringAttention.
  ///
  /// In id, this message translates to:
  /// **'Kasus perlu perhatian'**
  String get mobileCasesRequiringAttention;

  /// No description provided for @mobileNoCriticalCasesInThisArea.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kasus kritis pada cakupan ini.'**
  String get mobileNoCriticalCasesInThisArea;

  /// No description provided for @mobileDataQualitySynchronization.
  ///
  /// In id, this message translates to:
  /// **'Kualitas & sinkronisasi data'**
  String get mobileDataQualitySynchronization;

  /// No description provided for @mobileReportsReceivedByServer.
  ///
  /// In id, this message translates to:
  /// **'Laporan diterima server'**
  String get mobileReportsReceivedByServer;

  /// No description provided for @mobileOfflineDeviceQueuesAreAvailableInTheSyncCenter.
  ///
  /// In id, this message translates to:
  /// **'Antrean perangkat offline tersedia di pusat sinkronisasi.'**
  String get mobileOfflineDeviceQueuesAreAvailableInTheSyncCenter;

  /// No description provided for @mobileCitizenDataIsProtectedEveryOperatorDecisionIsRecorded.
  ///
  /// In id, this message translates to:
  /// **'Data warga terlindungi. Setiap keputusan operator dicatat dalam riwayat audit.'**
  String get mobileCitizenDataIsProtectedEveryOperatorDecisionIsRecorded;

  /// No description provided for @mobileReportsReceived.
  ///
  /// In id, this message translates to:
  /// **'Laporan masuk'**
  String get mobileReportsReceived;

  /// No description provided for @mobileCasesCompleted.
  ///
  /// In id, this message translates to:
  /// **'Kasus selesai'**
  String get mobileCasesCompleted;

  /// No description provided for @mobileNoTrendDataYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data tren'**
  String get mobileNoTrendDataYet;

  /// No description provided for @mobileWORKSPACE.
  ///
  /// In id, this message translates to:
  /// **'RUANG KERJA'**
  String get mobileWORKSPACE;

  /// No description provided for @mobileGOVERNANCE.
  ///
  /// In id, this message translates to:
  /// **'TATA KELOLA'**
  String get mobileGOVERNANCE;

  /// No description provided for @mobileOverview.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get mobileOverview;

  /// No description provided for @mobileMapCases.
  ///
  /// In id, this message translates to:
  /// **'Peta & Kasus'**
  String get mobileMapCases;

  /// No description provided for @mobileAIPreVerification.
  ///
  /// In id, this message translates to:
  /// **'Pra-Verifikasi AI'**
  String get mobileAIPreVerification;

  /// No description provided for @mobileTasksProgress.
  ///
  /// In id, this message translates to:
  /// **'Tugas & Progres'**
  String get mobileTasksProgress;

  /// No description provided for @mobileAnalyticsHeatmap.
  ///
  /// In id, this message translates to:
  /// **'Analitik & Heatmap'**
  String get mobileAnalyticsHeatmap;

  /// No description provided for @mobileExportReports.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Laporan'**
  String get mobileExportReports;

  /// No description provided for @mobileAdministration.
  ///
  /// In id, this message translates to:
  /// **'Administrasi'**
  String get mobileAdministration;

  /// No description provided for @mobileAllAreas.
  ///
  /// In id, this message translates to:
  /// **'Seluruh wilayah'**
  String get mobileAllAreas;

  /// No description provided for @mobileSearchCasesVillagesOrIDs.
  ///
  /// In id, this message translates to:
  /// **'⌕  Cari kasus, desa, atau ID…'**
  String get mobileSearchCasesVillagesOrIDs;

  /// No description provided for @mobileCitizenDataIsProtectedDecisionsAreRecordedInThe.
  ///
  /// In id, this message translates to:
  /// **'Data warga terlindungi. Keputusan tercatat dalam audit.'**
  String get mobileCitizenDataIsProtectedDecisionsAreRecordedInThe;

  /// No description provided for @mobileCurrentReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan Saat Ini'**
  String get mobileCurrentReport;

  /// No description provided for @mobileDuplicateCandidate.
  ///
  /// In id, this message translates to:
  /// **'Kandidat Duplikat'**
  String get mobileDuplicateCandidate;

  /// No description provided for @mobileSimilarity.
  ///
  /// In id, this message translates to:
  /// **'Kemiripan'**
  String get mobileSimilarity;

  /// No description provided for @mobileNearbyReports.
  ///
  /// In id, this message translates to:
  /// **'Laporan sekitar'**
  String get mobileNearbyReports;

  /// No description provided for @mobileChangeStatus.
  ///
  /// In id, this message translates to:
  /// **'Ubah Status'**
  String get mobileChangeStatus;

  /// No description provided for @mobileExportCase.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Kasus'**
  String get mobileExportCase;

  /// No description provided for @mobileAssignUnit.
  ///
  /// In id, this message translates to:
  /// **'Tugaskan Unit'**
  String get mobileAssignUnit;

  /// No description provided for @mobileVerifyPrioritize.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi & Prioritaskan'**
  String get mobileVerifyPrioritize;

  /// No description provided for @mobileDamageDimensions.
  ///
  /// In id, this message translates to:
  /// **'Catat ukuran kerusakan'**
  String get mobileDamageDimensions;

  /// No description provided for @mobileExampleLength2MWidth1M.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan ukuran beserta satuannya. Jika Anda belum mengukur, jelaskan alasannya.'**
  String get mobileExampleLength2MWidth1M;

  /// No description provided for @mobileTapAPhotoToReplaceItMaximum1MB.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto dari sudut yang berbeda agar admin dapat membandingkan kondisi. Ketuk foto untuk menggantinya; batas setiap foto 10 MB.'**
  String get mobileTapAPhotoToReplaceItMaximum1MB;

  /// No description provided for @mobileAlreadyRepaired.
  ///
  /// In id, this message translates to:
  /// **'Saya melihat masalah sudah ditangani'**
  String get mobileAlreadyRepaired;

  /// No description provided for @mobileResultsGoToTheOperatorForVerificationOfflineResults.
  ///
  /// In id, this message translates to:
  /// **'Kirim hasil agar admin dapat memeriksa temuan Anda. Jika perangkat tidak terhubung, simpan hasil ke antrean dan kirim saat internet tersedia.'**
  String get mobileResultsGoToTheOperatorForVerificationOfflineResults;

  /// No description provided for @mobileSaveDraft.
  ///
  /// In id, this message translates to:
  /// **'Simpan draf'**
  String get mobileSaveDraft;

  /// No description provided for @mobileNewDraft.
  ///
  /// In id, this message translates to:
  /// **'Draf baru'**
  String get mobileNewDraft;

  /// No description provided for @mobileDraftSaved.
  ///
  /// In id, this message translates to:
  /// **'Draf sudah disimpan'**
  String get mobileDraftSaved;

  /// No description provided for @mobileFIELDINSTRUCTIONS.
  ///
  /// In id, this message translates to:
  /// **'INSTRUKSI PETUGAS'**
  String get mobileFIELDINSTRUCTIONS;

  /// No description provided for @mobileREQUIREDCHECKLIST.
  ///
  /// In id, this message translates to:
  /// **'PEMERIKSAAN WAJIB'**
  String get mobileREQUIREDCHECKLIST;

  /// No description provided for @mobileCitizenEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti warga'**
  String get mobileCitizenEvidence;

  /// No description provided for @mobileNoCitizenPhotosYet.
  ///
  /// In id, this message translates to:
  /// **'Laporan ini belum memuat foto warga. Minta bukti tambahan jika Anda memerlukannya untuk menyiapkan survei.'**
  String get mobileNoCitizenPhotosYet;

  /// No description provided for @mobileSurveyResultsSubmitted.
  ///
  /// In id, this message translates to:
  /// **'Hasil survei terkirim'**
  String get mobileSurveyResultsSubmitted;

  /// No description provided for @mobileRequestClarification.
  ///
  /// In id, this message translates to:
  /// **'Minta penjelasan'**
  String get mobileRequestClarification;

  /// No description provided for @mobileDeclineTask.
  ///
  /// In id, this message translates to:
  /// **'Tolak tugas'**
  String get mobileDeclineTask;

  /// No description provided for @mobileSaveTask.
  ///
  /// In id, this message translates to:
  /// **'↓ Simpan tugas'**
  String get mobileSaveTask;

  /// No description provided for @mobileSaveAll.
  ///
  /// In id, this message translates to:
  /// **'↓ Simpan semua'**
  String get mobileSaveAll;

  /// No description provided for @mobileAvailableLocally.
  ///
  /// In id, this message translates to:
  /// **'✓ Tugas sudah Anda simpan'**
  String get mobileAvailableLocally;

  /// No description provided for @mobileDue.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu'**
  String get mobileDue;

  /// No description provided for @mobileNotSet.
  ///
  /// In id, this message translates to:
  /// **'Belum ditentukan'**
  String get mobileNotSet;

  /// No description provided for @mobileLocationNotSet.
  ///
  /// In id, this message translates to:
  /// **'Lokasi belum diisi'**
  String get mobileLocationNotSet;

  /// No description provided for @mobileNoSurveyResultsYetSubmittedResultsWillAppearHere.
  ///
  /// In id, this message translates to:
  /// **'Anda belum mengirim hasil survei. Setelah Anda mengirimnya, buka bagian ini untuk melihat kembali catatan dan bukti.'**
  String get mobileNoSurveyResultsYetSubmittedResultsWillAppearHere;

  /// No description provided for @mobileMyPublicIdentity.
  ///
  /// In id, this message translates to:
  /// **'Periksa privasi laporan'**
  String get mobileMyPublicIdentity;

  /// No description provided for @mobilePrivateVisibleOnlyToStaff.
  ///
  /// In id, this message translates to:
  /// **'SIGAP membatasi identitas akun kepada petugas berwenang.'**
  String get mobilePrivateVisibleOnlyToStaff;

  /// No description provided for @mobileIConfirmThisInformationAccuratelyDescribesWhatIObserved.
  ///
  /// In id, this message translates to:
  /// **'Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat.'**
  String get mobileIConfirmThisInformationAccuratelyDescribesWhatIObserved;

  /// No description provided for @mobileNearbyMap.
  ///
  /// In id, this message translates to:
  /// **'Peta sekitar'**
  String get mobileNearbyMap;

  /// No description provided for @mobilePublicCasesGeneralizedLocations.
  ///
  /// In id, this message translates to:
  /// **'Lihat laporan pada perkiraan lokasi publik'**
  String get mobilePublicCasesGeneralizedLocations;

  /// No description provided for @mobileReloadMap.
  ///
  /// In id, this message translates to:
  /// **'Muat ulang peta'**
  String get mobileReloadMap;

  /// No description provided for @mobileTapAPinToSeeFacilityDetailsPublicCoordinates.
  ///
  /// In id, this message translates to:
  /// **'Ketuk titik untuk membaca laporan. Peta ini memakai perkiraan lokasi publik; jangan menggunakannya sebagai petunjuk lokasi survei yang pasti.'**
  String get mobileTapAPinToSeeFacilityDetailsPublicCoordinates;

  /// No description provided for @mobileCasePriorityScore.
  ///
  /// In id, this message translates to:
  /// **'Skor prioritas kasus'**
  String get mobileCasePriorityScore;

  /// No description provided for @mobilePeopleAffected.
  ///
  /// In id, this message translates to:
  /// **'Jumlah terdampak'**
  String get mobilePeopleAffected;

  /// No description provided for @mobileSupportingReports.
  ///
  /// In id, this message translates to:
  /// **'Laporan pendukung'**
  String get mobileSupportingReports;

  /// No description provided for @mobileSLAOverdue.
  ///
  /// In id, this message translates to:
  /// **'Lewat batas waktu'**
  String get mobileSLAOverdue;

  /// No description provided for @mobileScoreNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Skor belum tersedia'**
  String get mobileScoreNotAvailable;

  /// No description provided for @mobileISSUEIMPACT.
  ///
  /// In id, this message translates to:
  /// **'DAMPAK MASALAH'**
  String get mobileISSUEIMPACT;

  /// No description provided for @mobileResidentsAffected.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas warga terdampak'**
  String get mobileResidentsAffected;

  /// No description provided for @mobileTimelineAndDecisions.
  ///
  /// In id, this message translates to:
  /// **'Linimasa & jejak keputusan'**
  String get mobileTimelineAndDecisions;

  /// No description provided for @mobileResidentPrivacyReporterIdentitiesAreExcludedFromThePublic.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan data warga\nIdentitas pelapor tidak disertakan dalam portal publik.'**
  String get mobileResidentPrivacyReporterIdentitiesAreExcludedFromThePublic;

  /// No description provided for @mobileNoAIResultsYetRunTheAssessmentToSee.
  ///
  /// In id, this message translates to:
  /// **'Belum ada hasil AI. Jalankan pemeriksaan untuk melihat hasil.'**
  String get mobileNoAIResultsYetRunTheAssessmentToSee;

  /// No description provided for @mobileAIAssessmentResults.
  ///
  /// In id, this message translates to:
  /// **'Hasil pra-verifikasi AI'**
  String get mobileAIAssessmentResults;

  /// No description provided for @mobileConsolidatedSupportingReports.
  ///
  /// In id, this message translates to:
  /// **'laporan pendukung terkonsolidasi'**
  String get mobileConsolidatedSupportingReports;

  /// No description provided for @mobileCaseActions.
  ///
  /// In id, this message translates to:
  /// **'Aksi kasus:'**
  String get mobileCaseActions;

  /// No description provided for @connectionOnline.
  ///
  /// In id, this message translates to:
  /// **'Terhubung'**
  String get connectionOnline;

  /// No description provided for @connectionOffline.
  ///
  /// In id, this message translates to:
  /// **'Tanpa koneksi'**
  String get connectionOffline;

  /// No description provided for @statusAwaitingClarification.
  ///
  /// In id, this message translates to:
  /// **'Menunggu klarifikasi'**
  String get statusAwaitingClarification;

  /// No description provided for @greetingPerson.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name} 👋'**
  String greetingPerson(String name);

  /// No description provided for @villageWithName.
  ///
  /// In id, this message translates to:
  /// **'Desa {name}'**
  String villageWithName(String name);

  /// No description provided for @conditionWithLabel.
  ///
  /// In id, this message translates to:
  /// **'Kondisi: {condition}'**
  String conditionWithLabel(String condition);

  /// No description provided for @reportCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} laporan}}'**
  String reportCount(int count);

  /// No description provided for @submittedResultCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} hasil terkirim}}'**
  String submittedResultCount(int count);

  /// No description provided for @pendingSyncCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} kiriman belum tersinkron}}'**
  String pendingSyncCount(int count);

  /// No description provided for @waitingSubmissionCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} kiriman menunggu}}'**
  String waitingSubmissionCount(int count);

  /// No description provided for @successfulSyncCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} kiriman berhasil tersinkron.}}'**
  String successfulSyncCount(int count);

  /// No description provided for @supportingReportCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} laporan pendukung}}'**
  String supportingReportCount(int count);

  /// No description provided for @protectedReportCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} laporan · identitas terlindungi}}'**
  String protectedReportCount(int count);

  /// No description provided for @photoProgress.
  ///
  /// In id, this message translates to:
  /// **'{count} dari {total} foto'**
  String photoProgress(int count, int total);

  /// No description provided for @taskSavedSummary.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas · {saved} tersimpan lokal'**
  String taskSavedSummary(int count, int saved);

  /// No description provided for @reportStepProgress.
  ///
  /// In id, this message translates to:
  /// **'Langkah {current} dari {total} · {label}'**
  String reportStepProgress(int current, int total, String label);

  /// No description provided for @distanceWithValue.
  ///
  /// In id, this message translates to:
  /// **'Jarak: {distance}'**
  String distanceWithValue(String distance);

  /// No description provided for @saveTaskFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan tugas: {error}'**
  String saveTaskFailed(String error);

  /// No description provided for @mergeReportFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menggabungkan: {error}'**
  String mergeReportFailed(String error);

  /// No description provided for @slaTargetDuration.
  ///
  /// In id, this message translates to:
  /// **'Target: {hours} jam ({days} hari)'**
  String slaTargetDuration(int hours, String days);

  /// No description provided for @categoryRoad.
  ///
  /// In id, this message translates to:
  /// **'Jalan'**
  String get categoryRoad;

  /// No description provided for @categoryBridge.
  ///
  /// In id, this message translates to:
  /// **'Jembatan'**
  String get categoryBridge;

  /// No description provided for @categoryCleanWater.
  ///
  /// In id, this message translates to:
  /// **'Air Bersih'**
  String get categoryCleanWater;

  /// No description provided for @categoryPublicFacility.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas Umum'**
  String get categoryPublicFacility;

  /// No description provided for @categoryIrrigation.
  ///
  /// In id, this message translates to:
  /// **'Irigasi'**
  String get categoryIrrigation;

  /// No description provided for @submissionFailedWithReason.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim: {error}'**
  String submissionFailedWithReason(String error);

  /// No description provided for @reportPhotoUploadRetry.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum berhasil mengunggah foto. Draf dan foto tetap tersedia; periksa koneksi lalu kirim kembali.'**
  String get reportPhotoUploadRetry;

  /// No description provided for @minimumEightCharacters.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get minimumEightCharacters;

  /// No description provided for @originalPhotoTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Foto asli melebihi 10 MB'**
  String get originalPhotoTooLarge;

  /// No description provided for @surveyPhotoTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 10 MB per foto. Pilih foto yang lebih kecil.'**
  String get surveyPhotoTooLarge;

  /// No description provided for @taskFieldEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti petugas lapangan'**
  String get taskFieldEvidence;

  /// No description provided for @taskNoFieldEvidence.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto bukti dari petugas lapangan.'**
  String get taskNoFieldEvidence;

  /// No description provided for @taskResolutionEvidence.
  ///
  /// In id, this message translates to:
  /// **'Bukti penanganan admin'**
  String get taskResolutionEvidence;

  /// No description provided for @taskNoResolutionEvidence.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto penanganan dari admin.'**
  String get taskNoResolutionEvidence;

  /// No description provided for @taskResolutionEvidenceExplanation.
  ///
  /// In id, this message translates to:
  /// **'Catatan: bukti petugas tetap tersimpan dan dapat dilihat kembali di bagian atas.'**
  String get taskResolutionEvidenceExplanation;

  /// No description provided for @reportAddressLabel.
  ///
  /// In id, this message translates to:
  /// **'Alamat lokasi'**
  String get reportAddressLabel;

  /// No description provided for @reportVillageLabel.
  ///
  /// In id, this message translates to:
  /// **'Desa/kelurahan'**
  String get reportVillageLabel;

  /// No description provided for @reportAddressLookupLoading.
  ///
  /// In id, this message translates to:
  /// **'SIGAP sedang mencari alamat titik ini…'**
  String get reportAddressLookupLoading;

  /// No description provided for @reportAddressLookupFailed.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum menemukan alamat untuk titik ini. Ketik alamat atau petunjuk lokasi agar petugas dapat menemukannya.'**
  String get reportAddressLookupFailed;

  /// No description provided for @reportAddressLookupRetry.
  ///
  /// In id, this message translates to:
  /// **'Cari alamat dari titik'**
  String get reportAddressLookupRetry;

  /// No description provided for @reportLocationInstruction.
  ///
  /// In id, this message translates to:
  /// **'Pilih titik tempat masalah terjadi, lalu periksa atau ketik alamatnya. Jangan gunakan lokasi perangkat jika Anda sedang berada di tempat lain.'**
  String get reportLocationInstruction;

  /// No description provided for @infrastructureLabel.
  ///
  /// In id, this message translates to:
  /// **'Infrastruktur'**
  String get infrastructureLabel;

  /// No description provided for @infrastructureReportLabel.
  ///
  /// In id, this message translates to:
  /// **'Laporan infrastruktur'**
  String get infrastructureReportLabel;

  /// No description provided for @supportingReportsUnknown.
  ///
  /// In id, this message translates to:
  /// **'Jumlah laporan pendukung belum tersedia'**
  String get supportingReportsUnknown;

  /// No description provided for @fieldSurveyLabel.
  ///
  /// In id, this message translates to:
  /// **'Survei lapangan'**
  String get fieldSurveyLabel;

  /// No description provided for @reportsUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Laporan belum dapat dimuat.'**
  String get reportsUnavailable;

  /// No description provided for @fieldWorkerLabel.
  ///
  /// In id, this message translates to:
  /// **'Petugas lapangan'**
  String get fieldWorkerLabel;

  /// No description provided for @saveSurveyToQueue.
  ///
  /// In id, this message translates to:
  /// **'Simpan ke antrean'**
  String get saveSurveyToQueue;

  /// No description provided for @submitSurveyResult.
  ///
  /// In id, this message translates to:
  /// **'Kirim hasil survei'**
  String get submitSurveyResult;

  /// No description provided for @timelineReportCreated.
  ///
  /// In id, this message translates to:
  /// **'Pelapor mengirim laporan'**
  String get timelineReportCreated;

  /// No description provided for @timelineAnonymousReportCreated.
  ///
  /// In id, this message translates to:
  /// **'Pelapor mengirim tanpa identitas akun'**
  String get timelineAnonymousReportCreated;

  /// No description provided for @reportStatusDraftExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menyimpan laporan ini di perangkat. Kirim laporan agar petugas dapat memeriksanya.'**
  String get reportStatusDraftExplanation;

  /// No description provided for @reportStatusSubmittedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan sudah masuk. Ikuti perkembangan di bawah ini; tahap ini belum menyatakan laporan benar atau selesai ditangani.'**
  String get reportStatusSubmittedExplanation;

  /// No description provided for @reportStatusReviewExplanation.
  ///
  /// In id, this message translates to:
  /// **'Petugas sedang memeriksa laporan dan bukti. Pantau perkembangan untuk melihat keputusan atau permintaan informasi tambahan.'**
  String get reportStatusReviewExplanation;

  /// No description provided for @reportStatusVerifiedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Petugas telah memverifikasi laporan. Ikuti catatan penugasan dan penanganan; verifikasi belum berarti pekerjaan selesai.'**
  String get reportStatusVerifiedExplanation;

  /// No description provided for @reportStatusProgressExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan memasuki tahap penanganan. Ikuti catatan pekerjaan untuk melihat hasil yang petugas kirim.'**
  String get reportStatusProgressExplanation;

  /// No description provided for @reportStatusResolvedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Penanganan laporan sudah selesai. Baca catatan hasil di bawah untuk melihat tindak lanjut yang tercatat.'**
  String get reportStatusResolvedExplanation;

  /// No description provided for @reportStatusRejectedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Petugas menolak laporan ini. Baca alasan keputusan; ajukan sanggahan jika Anda memiliki informasi yang perlu diperiksa kembali.'**
  String get reportStatusRejectedExplanation;

  /// No description provided for @reportStatusNeedsInfoExplanation.
  ///
  /// In id, this message translates to:
  /// **'Petugas meminta informasi tambahan. Baca permintaannya dan tambahkan bukti yang menjelaskan kondisi laporan.'**
  String get reportStatusNeedsInfoExplanation;

  /// No description provided for @reportStatusSurveyExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan memerlukan pemeriksaan lapangan. Ikuti catatan penugasan dan hasil kunjungan sebelum menyimpulkan penanganannya.'**
  String get reportStatusSurveyExplanation;

  /// No description provided for @reportStatusLinkedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan ini terhubung ke laporan lain. Buka laporan utama untuk mengikuti penanganan masalah yang sama.'**
  String get reportStatusLinkedExplanation;

  /// No description provided for @reportStatusUnknownExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum menerima informasi tahap penanganan yang dapat ditampilkan. Muat ulang untuk memeriksa pembaruan.'**
  String get reportStatusUnknownExplanation;

  /// No description provided for @reportStatusOutOfScopeExplanation.
  ///
  /// In id, this message translates to:
  /// **'Masalah ini berada di luar cakupan layanan laporan. Baca catatan keputusan untuk mengetahui arahan yang tersedia.'**
  String get reportStatusOutOfScopeExplanation;

  /// No description provided for @reportLocationMissingExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan ini belum memuat alamat. Gunakan catatan lokasi yang tersedia dan minta petunjuk jika Anda belum dapat menemukan tempatnya.'**
  String get reportLocationMissingExplanation;

  /// No description provided for @reportRelatedExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menghubungkan laporan ini ke laporan utama. Ikuti penanganan melalui tautan di bawah; jumlah pendukung bukan jumlah pekerjaan yang sudah selesai.'**
  String get reportRelatedExplanation;

  /// No description provided for @reportStandaloneExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan ini belum terhubung ke laporan utama lain. Ikuti perkembangan penanganannya pada halaman ini.'**
  String get reportStandaloneExplanation;

  /// No description provided for @reportPhotoMissingExplanation.
  ///
  /// In id, this message translates to:
  /// **'Laporan ini belum memuat foto. Tambahkan bukti bila petugas memintanya.'**
  String get reportPhotoMissingExplanation;

  /// No description provided for @reportPhotoLoadExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat membuka foto. Periksa koneksi lalu muat ulang laporan.'**
  String get reportPhotoLoadExplanation;

  /// No description provided for @mobileTechnicalDetails.
  ///
  /// In id, this message translates to:
  /// **'Lihat rincian teknis'**
  String get mobileTechnicalDetails;

  /// No description provided for @mobileRequestFailedExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat menyelesaikan permintaan ini. Periksa koneksi dan coba lagi. Jika masalah berulang, sertakan rincian teknis saat menghubungi petugas.'**
  String get mobileRequestFailedExplanation;

  /// No description provided for @mobileSyncItemFailedExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum mengirim kiriman ini. Periksa koneksi, pilih coba lagi, lalu kirim antrean kembali.'**
  String get mobileSyncItemFailedExplanation;

  /// No description provided for @mobileSyncLoadFailedExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat membaca antrean perangkat. Muat ulang sebelum memastikan bahwa semua kiriman sudah terkirim.'**
  String get mobileSyncLoadFailedExplanation;

  /// No description provided for @mobileNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur notifikasi perangkat'**
  String get mobileNotificationTitle;

  /// No description provided for @mobileNotificationEnabled.
  ///
  /// In id, this message translates to:
  /// **'SIGAP dapat menampilkan pembaruan laporan dan tugas saat aplikasi berada di latar belakang. Pengiriman tetap memerlukan koneksi perangkat.'**
  String get mobileNotificationEnabled;

  /// No description provided for @mobileNotificationDenied.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan Android untuk mengizinkan notifikasi, lalu aktifkan kembali di sini.'**
  String get mobileNotificationDenied;

  /// No description provided for @mobileNotificationFailed.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum dapat mendaftarkan perangkat untuk menerima notifikasi. Periksa koneksi dan coba lagi.'**
  String get mobileNotificationFailed;

  /// No description provided for @mobileNotificationUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini belum dapat menerima notifikasi dari SIGAP. Buka kotak pemberitahuan untuk memeriksa pembaruan.'**
  String get mobileNotificationUnavailable;

  /// No description provided for @mobileNotificationPrompt.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi agar Anda dapat mengikuti pembaruan laporan dan tugas pada perangkat ini.'**
  String get mobileNotificationPrompt;

  /// No description provided for @mobileNotificationEnabling.
  ///
  /// In id, this message translates to:
  /// **'SIGAP sedang mengaktifkan notifikasi…'**
  String get mobileNotificationEnabling;

  /// No description provided for @mobileNotificationEnable.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi'**
  String get mobileNotificationEnable;

  /// No description provided for @mobileNotificationDisable.
  ///
  /// In id, this message translates to:
  /// **'Nonaktifkan notifikasi'**
  String get mobileNotificationDisable;

  /// No description provided for @mobileAndroidSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan Android'**
  String get mobileAndroidSettings;

  /// No description provided for @taskLocationExplanation.
  ///
  /// In id, this message translates to:
  /// **'Cocokkan alamat dan titik laporan sebelum berangkat. Jika keduanya belum jelas, minta penjelasan kepada pemberi tugas.'**
  String get taskLocationExplanation;

  /// No description provided for @taskEvidenceExplanation.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan bukti pelapor dengan kondisi yang Anda temukan. Foto laporan membantu persiapan, tetapi tidak menggantikan pemeriksaan lapangan.'**
  String get taskEvidenceExplanation;

  /// No description provided for @taskResultsExplanation.
  ///
  /// In id, this message translates to:
  /// **'Catatan berikut menunjukkan hasil yang sudah petugas kirim. Bedakan pengiriman hasil dari persetujuan admin atas penyelesaian tugas.'**
  String get taskResultsExplanation;

  /// No description provided for @statisticsExplanation.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan ini menghitung laporan yang tersedia untuk akun Anda. Jumlah laporan tidak sama dengan jumlah pekerjaan; buka laporan untuk membaca tahap penanganannya.'**
  String get statisticsExplanation;

  /// No description provided for @gpsReadingExplanation.
  ///
  /// In id, this message translates to:
  /// **'Perangkat memperkirakan titik ini saat Anda merekamnya. Periksa akurasi dan waktu pengambilan; bacaan GPS saja tidak membuktikan kondisi fasilitas.'**
  String get gpsReadingExplanation;

  /// No description provided for @privacyReportExplanation.
  ///
  /// In id, this message translates to:
  /// **'Perlindungan identitas akun tidak menghapus data pribadi dalam foto atau uraian. Periksa kembali bukti sebelum Anda mengirimkannya.'**
  String get privacyReportExplanation;

  /// No description provided for @reportClosedStatus.
  ///
  /// In id, this message translates to:
  /// **'Ditutup'**
  String get reportClosedStatus;

  /// No description provided for @taskSubmittedStatus.
  ///
  /// In id, this message translates to:
  /// **'SIGAP menerima hasil'**
  String get taskSubmittedStatus;

  /// No description provided for @mobileSummaryUnavailable.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum menerima semua angka ringkasan. Buka daftar laporan untuk memeriksa data yang tersedia.'**
  String get mobileSummaryUnavailable;

  /// No description provided for @reportReviewExplanation.
  ///
  /// In id, this message translates to:
  /// **'Periksa foto, lokasi, waktu, dan uraian sebelum mengirim. Kembali ke langkah sebelumnya jika Anda perlu memperbaiki informasi.'**
  String get reportReviewExplanation;

  /// No description provided for @reportConditionUnknown.
  ///
  /// In id, this message translates to:
  /// **'Anda belum mencatat kondisi'**
  String get reportConditionUnknown;

  /// No description provided for @reportCaptureTimeUnknown.
  ///
  /// In id, this message translates to:
  /// **'Foto belum memuat waktu pengambilan yang dapat dibaca.'**
  String get reportCaptureTimeUnknown;

  /// No description provided for @reportImpactUnknown.
  ///
  /// In id, this message translates to:
  /// **'Anda belum menambahkan uraian dampak.'**
  String get reportImpactUnknown;

  /// No description provided for @categoryUnknown.
  ///
  /// In id, this message translates to:
  /// **'Kategori belum tercatat'**
  String get categoryUnknown;

  /// No description provided for @similarCaseHint.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan foto dan uraian. Tambahkan bukti hanya jika laporan tersebut membahas kejadian yang sama.'**
  String get similarCaseHint;

  /// No description provided for @gpsAccuracyMeaning.
  ///
  /// In id, this message translates to:
  /// **'Angka ini menunjukkan perkiraan ketelitian posisi, bukan jarak Anda dari fasilitas.'**
  String get gpsAccuracyMeaning;

  /// No description provided for @statusStepRecorded.
  ///
  /// In id, this message translates to:
  /// **'SIGAP mencatat tahap: {status}.'**
  String statusStepRecorded(String status);

  /// No description provided for @mobileRetryRequestExplanation.
  ///
  /// In id, this message translates to:
  /// **'SIGAP belum menyelesaikan permintaan ini. Periksa koneksi lalu coba lagi.'**
  String get mobileRetryRequestExplanation;

  /// No description provided for @selfCloseTitle.
  ///
  /// In id, this message translates to:
  /// **'Tandai Laporan Selesai'**
  String get selfCloseTitle;

  /// No description provided for @selfCloseDescription.
  ///
  /// In id, this message translates to:
  /// **'Anda yakin masalah ini sudah selesai dan tidak memerlukan penanganan lebih lanjut? Menandai laporan sebagai selesai akan membatalkan semua tugas petugas yang masih aktif untuk laporan ini.'**
  String get selfCloseDescription;

  /// No description provided for @selfCloseReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan Penutupan'**
  String get selfCloseReasonLabel;

  /// No description provided for @selfCloseReasonHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan mengapa Anda menandai laporan ini sebagai selesai...\n\nMinimal 10 karakter.'**
  String get selfCloseReasonHint;

  /// No description provided for @selfCloseSubmit.
  ///
  /// In id, this message translates to:
  /// **'Tutup Laporan'**
  String get selfCloseSubmit;

  /// No description provided for @selfCloseSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan Ditutup'**
  String get selfCloseSuccessTitle;

  /// No description provided for @selfCloseSuccessBody.
  ///
  /// In id, this message translates to:
  /// **'Laporan Anda sudah ditutup dan tidak akan diproses lebih lanjut. Anda dapat membuka kembali laporan ini melalui alur yang tersedia jika diperlukan.'**
  String get selfCloseSuccessBody;

  /// No description provided for @selfCloseReasonTooShort.
  ///
  /// In id, this message translates to:
  /// **'Alasan harus minimal {count} karakter'**
  String selfCloseReasonTooShort(int count);

  /// No description provided for @tandaiSelesaiSendiri.
  ///
  /// In id, this message translates to:
  /// **'Tandai Selesai Sendiri'**
  String get tandaiSelesaiSendiri;

  /// No description provided for @tandaiSelesaiSendiriCaption.
  ///
  /// In id, this message translates to:
  /// **'Anda menganggap masalah ini sudah selesai sendiri.'**
  String get tandaiSelesaiSendiriCaption;

  /// No description provided for @gamificationSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Kontribusi & Penghargaan'**
  String get gamificationSectionTitle;

  /// No description provided for @gamificationXpLabel.
  ///
  /// In id, this message translates to:
  /// **'XP'**
  String get gamificationXpLabel;

  /// No description provided for @gamificationLevelLabel.
  ///
  /// In id, this message translates to:
  /// **'Level'**
  String get gamificationLevelLabel;

  /// No description provided for @gamificationReputationLabel.
  ///
  /// In id, this message translates to:
  /// **'Reputasi'**
  String get gamificationReputationLabel;

  /// No description provided for @gamificationReputationUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Reputasi belum tersedia (min. 5 kontribusi dinilai)'**
  String get gamificationReputationUnavailable;

  /// No description provided for @gamificationReputationValue.
  ///
  /// In id, this message translates to:
  /// **'Reputasi: {value}% ({accepted}/{total} kontribusi)'**
  String gamificationReputationValue(String value, int accepted, int total);

  /// No description provided for @gamificationCountNewReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan baru'**
  String get gamificationCountNewReport;

  /// No description provided for @gamificationCountCorroboration.
  ///
  /// In id, this message translates to:
  /// **'Penguatan'**
  String get gamificationCountCorroboration;

  /// No description provided for @gamificationCountStatusChange.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan status'**
  String get gamificationCountStatusChange;

  /// No description provided for @gamificationBadgesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada lencana'**
  String get gamificationBadgesEmpty;

  /// No description provided for @gamificationLeaderboardOptInTitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan di Leaderboard Publik'**
  String get gamificationLeaderboardOptInTitle;

  /// No description provided for @gamificationLeaderboardOptInSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Leaderboard publik dapat dilihat di situs web SIGAP. Anda dapat berubah kapan saja.'**
  String get gamificationLeaderboardOptInSubtitle;

  /// No description provided for @gamificationLoadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data kontribusi'**
  String get gamificationLoadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
