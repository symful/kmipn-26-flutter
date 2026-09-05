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
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @rejected.
  ///
  /// In id, this message translates to:
  /// **'Rejected'**
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

  /// No description provided for @dashboardOperator.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Operator'**
  String get dashboardOperator;

  /// No description provided for @dashboardPengambilKeputusan.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Pengambil Keputusan'**
  String get dashboardPengambilKeputusan;

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

  /// No description provided for @detailKasusOperator.
  ///
  /// In id, this message translates to:
  /// **'Detail Kasus Operator'**
  String get detailKasusOperator;

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
  /// **'Kirim surveyor'**
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
  /// **'Masukkan ID surveyor'**
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
  /// **'Laporan tersimpan. Akan sinkron otomatis.'**
  String get laporanTersimpan;

  /// No description provided for @surveiBerhasilDikirim.
  ///
  /// In id, this message translates to:
  /// **'Survei berhasil dikirim!'**
  String get surveiBerhasilDikirim;

  /// No description provided for @simpanDanSinkronkanNanti.
  ///
  /// In id, this message translates to:
  /// **'Simpan dan sinkronkan nanti'**
  String get simpanDanSinkronkanNanti;

  /// No description provided for @submitFailed.
  ///
  /// In id, this message translates to:
  /// **'Submit failed'**
  String get submitFailed;

  /// No description provided for @kirimLaporan.
  ///
  /// In id, this message translates to:
  /// **'Kirim Laporan'**
  String get kirimLaporan;

  /// No description provided for @simpanProgress.
  ///
  /// In id, this message translates to:
  /// **'Simpan Progress'**
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
  /// **'Detail: {action}'**
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
  /// **'Unknown'**
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
  /// **'Diluar Jangkauan'**
  String get diluteJangkauan;

  /// No description provided for @dilute.
  ///
  /// In id, this message translates to:
  /// **'Diluar'**
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
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @verified.
  ///
  /// In id, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @inProgress.
  ///
  /// In id, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In id, this message translates to:
  /// **'Resolved'**
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
  /// **'Tugas survei akan muncul di sini'**
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
  /// **'SLA terdekat'**
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
  /// **'Filter Status'**
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
  /// **'Refresh'**
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
  /// **'Reset Filter'**
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

  /// No description provided for @verifikatorAntrian.
  ///
  /// In id, this message translates to:
  /// **'Verifikator - Antrian'**
  String get verifikatorAntrian;

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
  /// **'-'**
  String get tanpaDeskripsi;

  /// No description provided for @exportPdf.
  ///
  /// In id, this message translates to:
  /// **'Ekspor PDF'**
  String get exportPdf;

  /// No description provided for @pdfSaved.
  ///
  /// In id, this message translates to:
  /// **'PDF saved'**
  String get pdfSaved;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Error'**
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
  /// **'Timeline'**
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
  /// **'Merge'**
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
  /// **'Progress'**
  String get progress;

  /// No description provided for @clarification.
  ///
  /// In id, this message translates to:
  /// **'Clarification'**
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
  /// **'Clarifikasi'**
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
  /// **'Review laporan'**
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
  /// **'Aktifkan tema gelap untuk kenyamanan mata di malam hari'**
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

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

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
  /// **'AI Console'**
  String get aiConsole;

  /// No description provided for @auditLog.
  ///
  /// In id, this message translates to:
  /// **'Audit Log'**
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
  /// **'Assign'**
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

  /// No description provided for @kelolaWilayah.
  ///
  /// In id, this message translates to:
  /// **'Kelola Wilayah'**
  String get kelolaWilayah;

  /// No description provided for @tambahWilayah.
  ///
  /// In id, this message translates to:
  /// **'Tambah Wilayah'**
  String get tambahWilayah;

  /// No description provided for @tambahWilayahBaru.
  ///
  /// In id, this message translates to:
  /// **'Tambah Wilayah Baru'**
  String get tambahWilayahBaru;

  /// No description provided for @namaWilayahWajibDiisi.
  ///
  /// In id, this message translates to:
  /// **'Nama wilayah wajib diisi'**
  String get namaWilayahWajibDiisi;

  /// No description provided for @rtRw.
  ///
  /// In id, this message translates to:
  /// **'RT / RW'**
  String get rtRw;

  /// No description provided for @kelurahanDesa.
  ///
  /// In id, this message translates to:
  /// **'Kelurahan / Desa'**
  String get kelurahanDesa;

  /// No description provided for @kecamatan.
  ///
  /// In id, this message translates to:
  /// **'Kecamatan'**
  String get kecamatan;

  /// No description provided for @kotaKabupaten.
  ///
  /// In id, this message translates to:
  /// **'Kota / Kabupaten'**
  String get kotaKabupaten;

  /// No description provided for @provinsi.
  ///
  /// In id, this message translates to:
  /// **'Provinsi'**
  String get provinsi;

  /// No description provided for @hintWilayahName.
  ///
  /// In id, this message translates to:
  /// **'Misal: Kelurahan Cibadak'**
  String get hintWilayahName;

  /// No description provided for @hintParentWilayahId.
  ///
  /// In id, this message translates to:
  /// **'ID Wilayah Induk'**
  String get hintParentWilayahId;

  /// No description provided for @hintSearchWilayah.
  ///
  /// In id, this message translates to:
  /// **'Cari wilayah atau tingkat administratif...'**
  String get hintSearchWilayah;

  /// No description provided for @labelTingkatAdministratif.
  ///
  /// In id, this message translates to:
  /// **'Tingkat / Level Administratif'**
  String get labelTingkatAdministratif;

  /// No description provided for @labelParentIdWilayah.
  ///
  /// In id, this message translates to:
  /// **'Parent ID Wilayah (opsional)'**
  String get labelParentIdWilayah;

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

  /// No description provided for @namaUnitWilayahWajibDiisi.
  ///
  /// In id, this message translates to:
  /// **'Nama unit dan wilayah wajib diisi'**
  String get namaUnitWilayahWajibDiisi;

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

  /// No description provided for @hintWilayahSearch.
  ///
  /// In id, this message translates to:
  /// **'Misal: WIL-001 atau nama wilayah'**
  String get hintWilayahSearch;

  /// No description provided for @hintSearchUnit.
  ///
  /// In id, this message translates to:
  /// **'Cari unit atau wilayah...'**
  String get hintSearchUnit;

  /// No description provided for @labelKodeWilayah.
  ///
  /// In id, this message translates to:
  /// **'Kode / ID Wilayah (Wajib)'**
  String get labelKodeWilayah;

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

  /// No description provided for @surveyorVerifikasiFisik.
  ///
  /// In id, this message translates to:
  /// **'SURVEYOR (Verifikasi Fisik)'**
  String get surveyorVerifikasiFisik;

  /// No description provided for @verifikatorValidasi.
  ///
  /// In id, this message translates to:
  /// **'VERIFIKATOR (Validasi)'**
  String get verifikatorValidasi;

  /// No description provided for @operatorDisposisi.
  ///
  /// In id, this message translates to:
  /// **'OPERATOR (Disposisi)'**
  String get operatorDisposisi;

  /// No description provided for @adminDaerah.
  ///
  /// In id, this message translates to:
  /// **'ADMIN DAERAH'**
  String get adminDaerah;

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

  /// No description provided for @belumAdaWilayahTerdaftar.
  ///
  /// In id, this message translates to:
  /// **'Belum ada wilayah administratif yang terdaftar.'**
  String get belumAdaWilayahTerdaftar;

  /// No description provided for @tidakAdaWilayahCocok.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada wilayah yang cocok dengan pencarian'**
  String get tidakAdaWilayahCocok;

  /// No description provided for @daftarkanWilayah.
  ///
  /// In id, this message translates to:
  /// **'Daftarkan wilayah administratif (Kelurahan / Kecamatan / Kota) untuk penugasan dan filter laporan.'**
  String get daftarkanWilayah;

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
  /// **'Gagal capture GPS: {error}'**
  String gagalCaptureGps(String error);

  /// No description provided for @formSurvei.
  ///
  /// In id, this message translates to:
  /// **'Form Survei'**
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

  /// No description provided for @tugasDimulaiSurveyorLain.
  ///
  /// In id, this message translates to:
  /// **'Tugas sudah dimulai oleh surveyor lain'**
  String get tugasDimulaiSurveyorLain;

  /// No description provided for @tugasDiprosesSurveyorLain.
  ///
  /// In id, this message translates to:
  /// **'Tugas sudah diproses oleh surveyor lain'**
  String get tugasDiprosesSurveyorLain;

  /// No description provided for @gagalDenganError.
  ///
  /// In id, this message translates to:
  /// **'Gagal: {error}'**
  String gagalDenganError(String error);

  /// No description provided for @mintaClarifikasi.
  ///
  /// In id, this message translates to:
  /// **'Minta Clarifikasi'**
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
  /// **'Sync all'**
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
  /// **'Tampilan & Tema'**
  String get sectionTampilanTema;

  /// No description provided for @sectionBahasaLokalisasi.
  ///
  /// In id, this message translates to:
  /// **'Bahasa & Lokalisasi'**
  String get sectionBahasaLokalisasi;

  /// No description provided for @sectionInformasiAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Informasi Aplikasi'**
  String get sectionInformasiAplikasi;

  /// No description provided for @pilihSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Pilih surveyor'**
  String get pilihSurveyor;

  /// No description provided for @labelIdLaporanDuplikatWajib.
  ///
  /// In id, this message translates to:
  /// **'ID Laporan Duplikat (WAJIB)'**
  String get labelIdLaporanDuplikatWajib;

  /// No description provided for @labelPilihSurveyorWajib.
  ///
  /// In id, this message translates to:
  /// **'Pilih Surveyor (WAJIB)'**
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
  /// **'Semua notifikasi ditandai sudah dibaca'**
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
  /// **'Baca semua'**
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
  /// **'Laporan tersimpan. Akan sinkron otomatis.'**
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
  /// **'Error: {error}'**
  String errorDenganPesan(String error);

  /// No description provided for @mergeKasus.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan Kasus'**
  String get mergeKasus;

  /// No description provided for @fiturGabungkanSegeraHadir.
  ///
  /// In id, this message translates to:
  /// **'Fitur gabungkan kasus akan segera hadir.'**
  String get fiturGabungkanSegeraHadir;

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
  /// **'AI re-scan triggered successfully'**
  String get aiRescanBerhasil;

  /// No description provided for @aiRescanGagal.
  ///
  /// In id, this message translates to:
  /// **'Failed to trigger re-scan: {error}'**
  String aiRescanGagal(String error);

  /// No description provided for @retryScan.
  ///
  /// In id, this message translates to:
  /// **'Retry Scan'**
  String get retryScan;

  /// No description provided for @labelStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelConfidence.
  ///
  /// In id, this message translates to:
  /// **'Confidence'**
  String get labelConfidence;

  /// No description provided for @labelResult.
  ///
  /// In id, this message translates to:
  /// **'Result'**
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

  /// No description provided for @wilayah.
  ///
  /// In id, this message translates to:
  /// **'Wilayah'**
  String get wilayah;

  /// No description provided for @unitKerja.
  ///
  /// In id, this message translates to:
  /// **'Unit Kerja'**
  String get unitKerja;

  /// No description provided for @csvFormat.
  ///
  /// In id, this message translates to:
  /// **'CSV Format'**
  String get csvFormat;

  /// No description provided for @jsonFormat.
  ///
  /// In id, this message translates to:
  /// **'JSON Format'**
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
  /// **'Actor'**
  String get labelActor;

  /// No description provided for @labelTanggal.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get labelTanggal;

  /// No description provided for @exportLabel.
  ///
  /// In id, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @supportingFactors.
  ///
  /// In id, this message translates to:
  /// **'Supporting Factors'**
  String get supportingFactors;

  /// No description provided for @riskFactors.
  ///
  /// In id, this message translates to:
  /// **'Risk Factors'**
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
  /// **'SLA terlewat'**
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

  /// No description provided for @surveyorMenunggu.
  ///
  /// In id, this message translates to:
  /// **'Surveyor Menunggu'**
  String get surveyorMenunggu;

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
  /// **'Timeline'**
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
  /// **'Severity'**
  String get labelSeverity;

  /// No description provided for @labelScore.
  ///
  /// In id, this message translates to:
  /// **'Score'**
  String get labelScore;

  /// No description provided for @petugasLabelA.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get petugasLabelA;

  /// No description provided for @clarifikasiLabel.
  ///
  /// In id, this message translates to:
  /// **'Clarifikasi'**
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
  /// **'Audit & Integrity Monitoring'**
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
  /// **'Tidak Ada Notifikasi'**
  String get tidakAdaNotifikasi;

  /// No description provided for @pemberitahuanTerkait.
  ///
  /// In id, this message translates to:
  /// **'Pemberitahuan terkait laporan atau penugasan akan muncul di sini.'**
  String get pemberitahuanTerkait;

  /// No description provided for @gagalMemuatNotifikasi.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Notifikasi'**
  String get gagalMemuatNotifikasi;

  /// No description provided for @modeGelap.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get modeGelap;

  /// No description provided for @modeGelapSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan tema gelap untuk kenyamanan mata di malam hari'**
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
  /// **'Gunakan akun Anda untuk mengakses laporan.'**
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
  /// **'Email tidak boleh kosong'**
  String get emailKosong;

  /// No description provided for @emailTidakValid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get emailTidakValid;

  /// No description provided for @kataSandi.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get kataSandi;

  /// No description provided for @kataSandiKosong.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak boleh kosong'**
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
  /// **'Buat akun baru untuk memulai.'**
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
  /// **'Nama tidak boleh kosong'**
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
  /// **'Kata sandi tidak cocok'**
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

  /// No description provided for @wilayahAktif.
  ///
  /// In id, this message translates to:
  /// **'Wilayah aktif'**
  String get wilayahAktif;

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
  /// **'Tap untuk membuka kamera'**
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
  /// **'Laporan tersimpan dan terkirim.'**
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

  /// No description provided for @aksesWilayah.
  ///
  /// In id, this message translates to:
  /// **'Akses wilayah'**
  String get aksesWilayah;

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
  /// **'Tambahkan foto dan deskripsi untuk melengkapi laporan Anda.'**
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
  /// **'Jelaskan alasan keberatan Anda secara detail...'**
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
  /// **'Izin {title} diperlukan untuk melanjutkan. Silakan aktifkan izin di Pengaturan.'**
  String izinDiperlukanPesan(String title);

  /// No description provided for @berdasarkanStatus.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan Status'**
  String get berdasarkanStatus;

  /// No description provided for @berdasarkanKategori.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan Kategori'**
  String get berdasarkanKategori;

  /// No description provided for @aksesLokasiBody.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses lokasi untuk membantu kami menemukan masalah di sekitar Anda dengan lebih akurat.'**
  String get aksesLokasiBody;

  /// No description provided for @aksesKameraBody.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses kamera untuk mengambil foto bukti masalah yang ingin Anda laporkan.'**
  String get aksesKameraBody;

  /// No description provided for @notifikasiBody.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi untuk mendapatkan pembaruan tentang status laporan Anda.'**
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

  /// No description provided for @semuaSurveyorAktif.
  ///
  /// In id, this message translates to:
  /// **'Semua surveyor aktif'**
  String get semuaSurveyorAktif;

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
  /// **'API Error: {statusCode}'**
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
  /// **'Draft'**
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
  /// **'Unknown'**
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
  /// **'Gagal capture GPS: {error}'**
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
  /// **'Form Survei'**
  String get formSurveiTitle;

  /// No description provided for @kembaliKeDaftarTugasBtn.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Daftar Tugas'**
  String get kembaliKeDaftarTugasBtn;

  /// No description provided for @fotoPerSudut.
  ///
  /// In id, this message translates to:
  /// **'Foto per sudut'**
  String get fotoPerSudut;

  /// No description provided for @formSurveiHeader.
  ///
  /// In id, this message translates to:
  /// **'Form survei'**
  String get formSurveiHeader;

  /// No description provided for @gpsBelumTertangkap.
  ///
  /// In id, this message translates to:
  /// **'GPS Belum Tertangkap'**
  String get gpsBelumTertangkap;

  /// No description provided for @tidakDitemukanDiLokasi.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan di lokasi'**
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
  /// **'Error: {error}'**
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
  /// **'ID Laporan'**
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
  /// **'Sanggahan Berhasil Diajukan'**
  String get sanggahanBerhasil;

  /// No description provided for @sanggahanBerhasilDesc.
  ///
  /// In id, this message translates to:
  /// **'Sanggahan Anda untuk laporan {reportId} telah berhasil diajukan.'**
  String sanggahanBerhasilDesc(String reportId);

  /// No description provided for @filterAuditLog.
  ///
  /// In id, this message translates to:
  /// **'Filter Audit Log'**
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
  /// **'Actor: {value}'**
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

  /// No description provided for @wilayahFilter.
  ///
  /// In id, this message translates to:
  /// **'Wilayah: {value}'**
  String wilayahFilter(String value);

  /// No description provided for @wargaRole.
  ///
  /// In id, this message translates to:
  /// **'Warga'**
  String get wargaRole;

  /// No description provided for @surveyorRole.
  ///
  /// In id, this message translates to:
  /// **'Surveyor'**
  String get surveyorRole;

  /// No description provided for @petugasRole.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get petugasRole;

  /// No description provided for @operatorRole.
  ///
  /// In id, this message translates to:
  /// **'Operator'**
  String get operatorRole;

  /// No description provided for @verifikatorRole.
  ///
  /// In id, this message translates to:
  /// **'Verifikator'**
  String get verifikatorRole;

  /// No description provided for @adminDaerahRole.
  ///
  /// In id, this message translates to:
  /// **'Admin Daerah'**
  String get adminDaerahRole;

  /// No description provided for @auditorRole.
  ///
  /// In id, this message translates to:
  /// **'Auditor'**
  String get auditorRole;

  /// No description provided for @eksekutifRole.
  ///
  /// In id, this message translates to:
  /// **'Eksekutif'**
  String get eksekutifRole;

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

  /// No description provided for @tugasPenangananDariOperator.
  ///
  /// In id, this message translates to:
  /// **'Tugas penanganan dari operator akan muncul di sini saat ditugaskan.'**
  String get tugasPenangananDariOperator;

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
  /// **'Error: {error}'**
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
  /// **'Submitted'**
  String get submittedLabel;

  /// No description provided for @underReviewLabel.
  ///
  /// In id, this message translates to:
  /// **'Under Review'**
  String get underReviewLabel;

  /// No description provided for @inProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'In Progress'**
  String get inProgressLabel;

  /// No description provided for @resolvedLabel.
  ///
  /// In id, this message translates to:
  /// **'Resolved'**
  String get resolvedLabel;

  /// No description provided for @rejectedLabel.
  ///
  /// In id, this message translates to:
  /// **'Rejected'**
  String get rejectedLabel;

  /// No description provided for @verifiedLabel.
  ///
  /// In id, this message translates to:
  /// **'Verified'**
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
  /// **'Surveyor Menunggu'**
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
  /// **'Empty GeoJSON'**
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
  /// **'Kondisi aktual'**
  String get kondisiAktual;

  /// No description provided for @rekomendasiHasil.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi hasil'**
  String get rekomendasiHasil;

  /// No description provided for @ambilGPS.
  ///
  /// In id, this message translates to:
  /// **'Ambil GPS'**
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
  /// **'Ringkasan eksekutif, analisis tren verifikasi, dan statistik wilayah.'**
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

  /// No description provided for @wilayahPrefix.
  ///
  /// In id, this message translates to:
  /// **'Wilayah: {value}'**
  String wilayahPrefix(String value);

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
  /// **'Best Practice'**
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
  /// **'Sanggahan adalah cara Anda untuk mengajukan keberatan terhadap keputusan yang telah diambil terhadap laporan Anda. Jika Anda merasa laporan Anda ditolak atau diputuskan secara tidak adil, Anda dapat mengajukan sanggahan formal yang akan ditinjau oleh tim verifier.'**
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
  /// **'Resource: {resource}'**
  String resourceLabel(String resource);

  /// No description provided for @gpsBerhasilDitangkap.
  ///
  /// In id, this message translates to:
  /// **'GPS berhasil ditangkap: {lat}, {lng}'**
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
  /// **'Valid — perlu tindak lanjut'**
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
  /// **'Data survei tersimpan lokal. Akan dikirim otomatis saat online.'**
  String get dataSurveiTersimpanLokal;

  /// No description provided for @dataSurveiTersimpanDiproses.
  ///
  /// In id, this message translates to:
  /// **'Data survei telah tersimpan dan akan diproses oleh tim terkait.'**
  String get dataSurveiTersimpanDiproses;

  /// No description provided for @hintCatatanLapangan.
  ///
  /// In id, this message translates to:
  /// **'Lubang melebar sejak laporan warga, sudah ada tanda darurat dari RW.'**
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
  /// **'Ketuk untuk menangkap koordinat GPS'**
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

  /// No description provided for @surveyorPerluDitugaskan.
  ///
  /// In id, this message translates to:
  /// **'{count} surveyor perlu ditugaskan'**
  String surveyorPerluDitugaskan(int count);

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
  /// **'Tugas penanganan dari operator akan muncul di sini saat ditugaskan.'**
  String get tugasPetugasDeskripsi;

  /// No description provided for @terlambatXjam.
  ///
  /// In id, this message translates to:
  /// **'Terlambat {hours}h'**
  String terlambatXjam(int hours);

  /// No description provided for @slaXjam.
  ///
  /// In id, this message translates to:
  /// **'SLA {hours}j'**
  String slaXjam(int hours);

  /// No description provided for @slaBesok.
  ///
  /// In id, this message translates to:
  /// **'SLA besok'**
  String get slaBesok;

  /// No description provided for @slaXhari.
  ///
  /// In id, this message translates to:
  /// **'SLA {days}d'**
  String slaXhari(int days);

  /// No description provided for @verifikatorMemintaInfo.
  ///
  /// In id, this message translates to:
  /// **'Verifikator meminta informasi tambahan untuk melengkapi laporan ini.'**
  String get verifikatorMemintaInfo;

  /// No description provided for @tenggatTanggal.
  ///
  /// In id, this message translates to:
  /// **'Tenggat {date}.'**
  String tenggatTanggal(String date);

  /// No description provided for @eventFallback.
  ///
  /// In id, this message translates to:
  /// **'Kejadian'**
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
  /// **'Kelola master wilayah, unit UPT, SLA, dan konfigurasi bobot prioritas.'**
  String get roleDescAdmin;

  /// No description provided for @roleDescOperator.
  ///
  /// In id, this message translates to:
  /// **'Disposisi penugasan, eskalasi kasus, dan monitoring antrean laporan.'**
  String get roleDescOperator;

  /// No description provided for @roleDescVerifikator.
  ///
  /// In id, this message translates to:
  /// **'Validasi kelayakan laporan pengaduan masuk dan tinjauan kebenaran.'**
  String get roleDescVerifikator;

  /// No description provided for @roleDescPetugas.
  ///
  /// In id, this message translates to:
  /// **'Tindak lanjut teknis lapangan dan penyelesaian masalah pengaduan.'**
  String get roleDescPetugas;

  /// No description provided for @roleDescSurveyor.
  ///
  /// In id, this message translates to:
  /// **'Survei dan peninjauan fisik lapangan dengan formulir teknis.'**
  String get roleDescSurveyor;

  /// No description provided for @roleDescAuditor.
  ///
  /// In id, this message translates to:
  /// **'Inspeksi jejak audit, log aktivitas sistem, dan pelaporan compliance.'**
  String get roleDescAuditor;

  /// No description provided for @roleDescWarga.
  ///
  /// In id, this message translates to:
  /// **'Kirim laporan pengaduan publik dan pantau status penyelesaian.'**
  String get roleDescWarga;

  /// No description provided for @roleDescExec.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan eksekutif, analisis tren verifikasi, dan statistik wilayah.'**
  String get roleDescExec;

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
  /// **'Draft'**
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
  /// **'Dalam Review'**
  String get dalamReviewLabelStatus;

  /// No description provided for @noAssessmentFactors.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada faktor penilaian yang tersedia.'**
  String get noAssessmentFactors;

  /// No description provided for @latitude.
  ///
  /// In id, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In id, this message translates to:
  /// **'Longitude'**
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
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In id, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusSyncing.
  ///
  /// In id, this message translates to:
  /// **'Syncing'**
  String get statusSyncing;

  /// No description provided for @statusErrorLabel.
  ///
  /// In id, this message translates to:
  /// **'Error'**
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
  /// **'Default: privat · hanya petugas melihat'**
  String get defaultPrivatPetugas;

  /// No description provided for @severityColonValue.
  ///
  /// In id, this message translates to:
  /// **'Severity: {value}'**
  String severityColonValue(Object value);

  /// No description provided for @scoreColonValue.
  ///
  /// In id, this message translates to:
  /// **'Score: {value}'**
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
  /// **'CHECKLIST WAJIB'**
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
  /// **'N/A'**
  String get naLabel;

  /// No description provided for @lessThan1dLabel.
  ///
  /// In id, this message translates to:
  /// **'<1d'**
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
  /// **'Submitted'**
  String get labelSubmitted;

  /// No description provided for @labelUnderReview.
  ///
  /// In id, this message translates to:
  /// **'Under Review'**
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
