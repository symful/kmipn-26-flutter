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

  /// No description provided for @verifikasiRTRW.
  ///
  /// In id, this message translates to:
  /// **'Verifikasi RT_RW'**
  String get verifikasiRTRW;

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

  /// No description provided for @pelatihanRTRW.
  ///
  /// In id, this message translates to:
  /// **'Pelatihan RT/RW'**
  String get pelatihanRTRW;

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
