// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SIGAP';

  @override
  String get batal => 'Cancel';

  @override
  String get simpan => 'Save';

  @override
  String get kirim => 'Submit';

  @override
  String get tolak => 'Reject';

  @override
  String get alasanPenolakan => 'Rejection Reason';

  @override
  String get selesai => 'Done';

  @override
  String get submitted => 'Submitted';

  @override
  String get rejected => 'Rejected';

  @override
  String get lihatSemua => 'View all';

  @override
  String get cobaLagi => 'Try Again';

  @override
  String get gagal => 'Failed';

  @override
  String get tutup => 'Close';

  @override
  String get lihatDiPeta => 'View on Map';

  @override
  String get detail => 'Detail';

  @override
  String get hapusSemua => 'Delete All';

  @override
  String get kirimBukti => 'Send Evidence';

  @override
  String get beranda => 'Home';

  @override
  String get tugas => 'Task';

  @override
  String get buat => 'Create';

  @override
  String get notifikasi => 'Notification';

  @override
  String get profil => 'Profile';

  @override
  String get laporan => 'Report';

  @override
  String get peta => 'Map';

  @override
  String get akun => 'Account';

  @override
  String get terima => 'Accept';

  @override
  String get menunggu => 'Waiting';

  @override
  String get proses => 'Process';

  @override
  String get diterima => 'Accepted';

  @override
  String get perluTindakan => 'Needs Action';

  @override
  String get diproses => 'In Progress';

  @override
  String get status => 'Status';

  @override
  String get kategori => 'Category';

  @override
  String get nama => 'Name';

  @override
  String get deskripsi => 'Description';

  @override
  String get lokasi => 'Location';

  @override
  String get tanggal => 'Date';

  @override
  String get jumlah => 'Amount';

  @override
  String get prioritas => 'Priority';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get daftarKasus => 'Case List';

  @override
  String get detailKasus => 'Case Detail';

  @override
  String get detailKasusVerifikasi => 'Case Detail - Verification';

  @override
  String get detailLaporan => 'Report Detail';

  @override
  String get detailTugas => 'Task Detail';

  @override
  String get laporanSaya => 'My Reports';

  @override
  String get belumAdaAktivitas => 'No activity yet';

  @override
  String get kirimBuktiTambahan => 'Send Additional Evidence';

  @override
  String get belumAdaFoto => 'No photos yet';

  @override
  String get survei => 'Survey';

  @override
  String get kirimSurveyor => 'Send Petugas';

  @override
  String get tolakLaporan => 'Reject Report';

  @override
  String get kirimKeputusan => 'Send Decision';

  @override
  String get masukkanIdLaporanDuplikat => 'Enter duplicate report ID';

  @override
  String get masukkanIdSurveyor => 'Enter petugas ID';

  @override
  String get petugasAktif => 'Active Officers';

  @override
  String get namaWilayahWAJIB => 'Region Name (REQUIRED)';

  @override
  String get namaUnitWAJIB => 'Unit Name (REQUIRED)';

  @override
  String get namaWAJIB => 'Name (REQUIRED)';

  @override
  String get simpanKonfigurasi => 'Save Configuration';

  @override
  String get tolakTugas => 'Reject Task';

  @override
  String get masukkanAlasanPenolakan => 'Enter rejection reason...';

  @override
  String get masukkanPertanyaanAnda => 'Enter your question...';

  @override
  String get alasanPemisahan =>
      'Enter reason why this case needs to be separated';

  @override
  String get idUnitTugas => 'Enter task unit ID';

  @override
  String get alasanMerge => 'Enter case ID to merge';

  @override
  String get laporanTersimpan =>
      'SIGAP saved the report on this device. Check its delivery in the sync center.';

  @override
  String get surveiBerhasilDikirim => 'You have submitted the survey results.';

  @override
  String get simpanDanSinkronkanNanti => 'Save and sync later';

  @override
  String get submitFailed => 'Submit failed';

  @override
  String get kirimLaporan => 'Submit Report';

  @override
  String get simpanProgress => 'Save progress';

  @override
  String get kirimVerifikasi => 'Submit Verification';

  @override
  String get mengirirmuatan => 'Sending...';

  @override
  String get rw => 'RW';

  @override
  String get rwMinus => 'RW -';

  @override
  String get prioritasSlider => 'Priority';

  @override
  String get lanjutKeReviewHasil => 'Continue to review results';

  @override
  String get hariIni => 'Today';

  @override
  String get terlambat => 'Late';

  @override
  String get belumDiunduh => 'Not downloaded';

  @override
  String get sinkron => 'Sync';

  @override
  String get riwayat => 'History';

  @override
  String get kasusTerdekat => 'Nearest Case';

  @override
  String get lihatPeta => 'View map';

  @override
  String get lihatArrow => 'View →';

  @override
  String get hapusUnduhanOffline => 'Delete offline download';

  @override
  String detailPerubahan(String action) {
    return 'Detail: $action';
  }

  @override
  String get lihatDetailPerubahan => 'View change details';

  @override
  String laporanIdDuplikat(String reportId) {
    return 'Report: $reportId';
  }

  @override
  String get idLaporanDuplikat => 'Enter duplicate report ID';

  @override
  String get keluar => 'Exit';

  @override
  String get detailLaporanVerifikasi => 'Verification Report Detail';

  @override
  String get laporanDuplicate => 'Duplicate report';

  @override
  String get perluTindakanCapital => 'Needs Action';

  @override
  String get ditolak => 'Rejected';

  @override
  String get duplikat => 'Duplicate';

  @override
  String get perluSurvei => 'Needs Survey';

  @override
  String get unknown => 'Information not recorded';

  @override
  String get mergeDuplikat => 'Merge duplicate';

  @override
  String get tandaiDuplikat => 'Mark as Duplicate';

  @override
  String get diluteJangkauan => 'Outside service area';

  @override
  String get dilute => 'Outside service area';

  @override
  String get perluKelengkapan => 'Needs completion';

  @override
  String get perluDilengkapi => 'Needs to be completed';

  @override
  String get underReview => 'Under Review';

  @override
  String get verified => 'Verified';

  @override
  String get inProgress => 'In Progress';

  @override
  String get resolved => 'Resolved';

  @override
  String get konfirmasi => 'Confirm';

  @override
  String get filter => 'Filter';

  @override
  String get reset => 'Reset';

  @override
  String get tersimpan => 'Saved';

  @override
  String get tersimpanDiPerangkat => 'Saved on device';

  @override
  String get perluTindakanAnda => 'Needs your action';

  @override
  String get idLaporanDuplikatHint => 'Enter duplicate report ID';

  @override
  String get mengirim => 'Sending...';

  @override
  String get tanpaJudul => 'No title';

  @override
  String get baruSaja => 'Just now';

  @override
  String get tidakAdaTugas => 'No tasks';

  @override
  String get tugasSurveiAkanMuncul =>
      'Open this list after an admin assigns a survey to you.';

  @override
  String get gagalMemuatTugas => 'Failed to load tasks';

  @override
  String get belumAdaRiwayat => 'No history yet';

  @override
  String get visitYangDikirimAkanMuncul => 'Sent visits will appear here';

  @override
  String get gagalMemuatRiwayat => 'Failed to load history';

  @override
  String get terbaru => 'Latest';

  @override
  String get slaTerdekat => 'Nearest deadline';

  @override
  String get sinkronkan => 'Synchronize';

  @override
  String get kemarin => 'Yesterday';

  @override
  String get hariYangLalu => 'days ago';

  @override
  String get mingguYangLalu => 'weeks ago';

  @override
  String get jamYangLalu => 'hours ago';

  @override
  String get menitYangLalu => 'minutes ago';

  @override
  String get filterAntrean => 'Queue Filter';

  @override
  String get terapkan => 'Apply';

  @override
  String get sortir => 'Sort';

  @override
  String get filterStatus => 'Filter Status';

  @override
  String get prioritasTertinggi => 'Highest Priority';

  @override
  String get semua => 'All';

  @override
  String get dalamProses => 'In Process';

  @override
  String get diverifikasi => 'Verified';

  @override
  String get laporanDiterima => 'Report accepted';

  @override
  String get laporanTidakJelas => 'Unclear report';

  @override
  String get refresh => 'Refresh';

  @override
  String get tidakAdaKasus => 'No Cases';

  @override
  String get tidakAdaKasusDenganFilter => 'No cases with filter';

  @override
  String get belumAdaKasusMasuk => 'No cases incoming.';

  @override
  String get resetFilter => 'Reset Filter';

  @override
  String get tidakAdaLaporanDiAntrean => 'No Reports in Queue';

  @override
  String get tidakAdaLaporanSesuaiFilter =>
      'No reports matching active filter.';

  @override
  String get semuaLaporanSelesaiDiverifikasi =>
      'All incoming reports have been verified.';

  @override
  String get hapusFilter => 'Remove Filter';

  @override
  String get adminAntrian => 'Admin - Queue';

  @override
  String get labelWilayahAktif => 'Active region';

  @override
  String get buatLaporan => 'Create report';

  @override
  String get fotoLokasiKondisi => 'Photo, location, and field conditions';

  @override
  String get laporanYangAndaKirimkan =>
      'Reports you submit will be recorded here.';

  @override
  String get tanpaDeskripsi => 'The reporter has not added a description.';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get pdfSaved => 'PDF saved';

  @override
  String get error => 'Error';

  @override
  String get terkirim => 'Sent';

  @override
  String get verifikasi => 'Verification';

  @override
  String get kembali => 'Back';

  @override
  String get belumDisinkronkan => 'Not yet synced to server';

  @override
  String get foto => 'Photo';

  @override
  String get timeline => 'Timeline';

  @override
  String get tindakan => 'Action';

  @override
  String get valid => 'Valid';

  @override
  String get rendah => 'Low';

  @override
  String get tinggi => 'High';

  @override
  String get merge => 'Merge';

  @override
  String get eskalasi => 'Escalation';

  @override
  String get baru => 'New';

  @override
  String get ditugaskan => 'Assigned';

  @override
  String get mengerjakan => 'Working on';

  @override
  String get unduh => 'Download';

  @override
  String get instruksi => 'Instructions';

  @override
  String get progress => 'Progress';

  @override
  String get clarification => 'Clarification';

  @override
  String get diselesaikan => 'Completed';

  @override
  String get item => 'Item';

  @override
  String get klarifikasi => 'Clarification';

  @override
  String get kunjungi => 'Visit';

  @override
  String get akurasiBaik => 'Good accuracy';

  @override
  String get berat => 'Heavy';

  @override
  String get siapOffline => 'Ready for offline';

  @override
  String get semuaTersinkron => 'All synchronized';

  @override
  String get gagalDikirim => 'Failed to send';

  @override
  String get sedangDiperiksa => 'Being checked';

  @override
  String get lengkapiLaporan => 'Complete report';

  @override
  String get reviewLaporan => 'Review report';

  @override
  String get unduhBatch => 'Download batch';

  @override
  String get beralihPeran => 'Switch Role';

  @override
  String get sinkronLabel => 'Sync';

  @override
  String get pengaturan => 'Settings';

  @override
  String get english => 'English';

  @override
  String get tinggal => 'Remaining';

  @override
  String get kasusDilaporkan => 'cases reported';

  @override
  String get recentActivity => 'Just now';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle =>
      'Use a dark background when reading the app in low light.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get bahasaIndonesia => 'Indonesian';

  @override
  String get englishUs => 'English (US)';

  @override
  String get sedang => 'Medium';

  @override
  String get masuk => 'Login';

  @override
  String get daftar => 'Register';

  @override
  String get statistik => 'Statistics';

  @override
  String get exportData => 'Export Data';

  @override
  String get aiConsole => 'AI Console';

  @override
  String get auditLog => 'Audit Log';

  @override
  String get sanggahan => 'Objection';

  @override
  String get kamera => 'Camera';

  @override
  String get galeri => 'Gallery';

  @override
  String get setuju => 'Approve';

  @override
  String get mintaInfo => 'Request Info';

  @override
  String get assign => 'Assign';

  @override
  String get petaLaporan => 'Report Map';

  @override
  String get ketukPetaUntukMemilihLokasi => 'Tap the map to select location';

  @override
  String get terapkanFilter => 'Apply Filter';

  @override
  String get segarkan => 'Refresh';

  @override
  String get segarkanData => 'Refresh Data';

  @override
  String get heatmap => 'Heatmap';

  @override
  String get pilihLokasi => 'Select Location';

  @override
  String get pusatIndonesia => 'Center Indonesia';

  @override
  String get lokasiSaya => 'My Location';

  @override
  String get tidakAdaTugasUntukDiunduh => 'No tasks to download';

  @override
  String get kelolaUnit => 'Manage Units';

  @override
  String get tambahUnit => 'Add Unit';

  @override
  String get tambahUnitBaru => 'Add New Unit';

  @override
  String get namaUnitWajibDiisi => 'Unit name is required';

  @override
  String get tidakAdaUnit => 'No Units';

  @override
  String get hintUnitName => 'e.g. Public Works, Satpol PP';

  @override
  String get hintSearchUnit => 'Search unit or region...';

  @override
  String get kelolaKategori => 'Manage Categories';

  @override
  String get tambahKategori => 'Add Category';

  @override
  String get tambahKategoriBaru => 'Add New Category';

  @override
  String get namaKategoriWajibDiisi => 'Category name is required';

  @override
  String get tidakAdaKategori => 'No Categories';

  @override
  String get hintKategoriName => 'e.g. Road Damage, Illegal Trash';

  @override
  String get hintKategoriSlug => 'e.g. road-damage';

  @override
  String get hintKategoriIcon => 'e.g. road, trash, lightbulb';

  @override
  String get hintSearchKategori => 'Search category by name or slug...';

  @override
  String get labelSlug => 'Slug (optional)';

  @override
  String get labelIcon => 'Icon / Symbol (optional)';

  @override
  String get kelolaAkun => 'Manage Accounts';

  @override
  String get tambahAkun => 'Add Account';

  @override
  String get tambahAkunBaru => 'Add New Account';

  @override
  String get emailNamaWajibDiisi => 'Email and name are required';

  @override
  String get tidakAdaAkun => 'No Accounts';

  @override
  String get petugasLapangan => 'OFFICER (Field)';

  @override
  String get hintEmail => 'example@region.go.id';

  @override
  String get hintNamaLengkap => 'Full name';

  @override
  String get labelEmailWajib => 'Email (Required)';

  @override
  String get labelPeranRole => 'Role';

  @override
  String get gagalMemuatWilayah => 'Failed to Load Region';

  @override
  String get tidakAdaWilayah => 'No Regions';

  @override
  String get tambahPengguna => 'Add User';

  @override
  String get masukkanInformasi =>
      'Enter new user account information for the SIGAP system.';

  @override
  String get belumAdaUnitKerjaTerdaftar => 'No work units registered yet.';

  @override
  String get daftarkanUnit =>
      'Register Technical Implementation Units (UPT / SKPD / Department) responsible for handling reports.';

  @override
  String get tambahUnitKerja => 'Add Work Unit';

  @override
  String get belumAdaKategoriLaporanTerdaftar =>
      'No report categories registered yet.';

  @override
  String get buatKategori =>
      'Create new report categories to facilitate community complaint classification.';

  @override
  String get belumAdaAkunPenggunaTerdaftar =>
      'No user accounts registered yet.';

  @override
  String get tidakAdaPenggunaDenganPeran => 'No users with the role';

  @override
  String get semuaRole => 'All Roles';

  @override
  String get konfigurasiSLA => 'SLA Configuration';

  @override
  String get tidakAdaDataSLA => 'No SLA Data';

  @override
  String get editSLA => 'Edit SLA';

  @override
  String get labelTargetSLA => 'SLA Target Time (hours)';

  @override
  String get hintContohSLA => 'e.g. 24, 48, 72';

  @override
  String get izinkanLokasiDitolak => 'Location permission denied';

  @override
  String gagalCaptureGps(String error) {
    return 'SIGAP could not read the device location. Check location permissions and try again. Details: $error';
  }

  @override
  String get formSurvei => 'Record survey findings';

  @override
  String get kembaliKeDaftarTugas => 'Back to Task List';

  @override
  String berhasilMengunduhTugas(int count) {
    return 'Successfully downloaded $count tasks';
  }

  @override
  String get tugasDimulaiPetugasLain =>
      'This task has changed or does not allow that action. Reload it and check its stage before trying again.';

  @override
  String get tugasDiprosesPetugasLain =>
      'Task has been processed by another officer';

  @override
  String gagalDenganError(String error) {
    return 'Failed: $error';
  }

  @override
  String get mintaClarifikasi => 'Ask for clarification';

  @override
  String get unduhSemuaOffline => 'Download all for offline';

  @override
  String get hintMasukkanAlasan => 'Enter reason...';

  @override
  String get hintTulisPertanyaan => 'Type your question...';

  @override
  String get labelAlasanPenolakan => 'Rejection reason';

  @override
  String get labelPertanyaanKlarifikasi => 'Question / clarification';

  @override
  String get ambilUlangFoto => 'Retake Photo';

  @override
  String get pilihDiPeta => 'Select on Map';

  @override
  String gagalHapusMetadataFoto(String error) {
    return 'Failed to delete photo metadata: $error';
  }

  @override
  String get lokasiTidakTersedia => 'Location Unavailable';

  @override
  String get ambilFotoTerlebihDahulu => 'Take a photo first';

  @override
  String get aktifkanLokasiUntukMelapor => 'Enable location to report';

  @override
  String get pilihKategoriTerlebihDahulu => 'Select a category first';

  @override
  String gagalMenyimpan(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get tapUntukMemilihKategori => 'Tap to select category';

  @override
  String get minimal10Karakter => 'Minimum 10 characters...';

  @override
  String get labelPilihKategori => 'Select Category';

  @override
  String get labelJelaskanLaporan => 'Describe your report';

  @override
  String get labelPerkiraanTerdampak => 'Estimated affected residents';

  @override
  String get sectionAmbilFoto => 'Take Photo';

  @override
  String get sectionLokasi => 'Location';

  @override
  String get sectionDeskripsi => 'Description';

  @override
  String get sectionPerkiraanTerdampak => 'Estimated Affected Count';

  @override
  String get sectionTingkatKerentanan => 'Vulnerability Level';

  @override
  String get sectionDampak => 'Impact';

  @override
  String get csvSpreadsheet => 'CSV (Spreadsheet)';

  @override
  String get geoJsonGeospatial => 'GeoJSON (Geospatial)';

  @override
  String get pdfLaporan => 'PDF (Report)';

  @override
  String get itemDikembalikanKeAntrian => 'Item returned to queue';

  @override
  String get syncAll => 'Sync all';

  @override
  String get totalLaporan => 'Total Reports';

  @override
  String get totalKasus => 'Total Cases';

  @override
  String get silakanTambahFotoDahulu => 'Please add a photo first';

  @override
  String get laporanBerhasilDilengkapi => 'Report successfully completed';

  @override
  String gagalMelengkapiLaporan(String error) {
    return 'Failed to complete report: $error';
  }

  @override
  String get sanggahanBerhasilDiajukan => 'Objection successfully submitted';

  @override
  String get perjalananLaporanDitampilkan =>
      'Report journey will be displayed here.';

  @override
  String get labelTingkatPrioritas => 'Priority Level';

  @override
  String get labelDibuat => 'Created';

  @override
  String get lengkapiLaporanLabel => 'Complete report';

  @override
  String get sanggahKeputusan => 'Object to Decision';

  @override
  String get kirimLabel => 'Submit';

  @override
  String get ajukanSanggahanLabel => 'Submit Objection';

  @override
  String get portalPublik => 'Public Portal';

  @override
  String get belumAdaLaporan => 'No Reports Yet';

  @override
  String get labelProgres => 'Progress';

  @override
  String get labelDukungan => 'Support';

  @override
  String get labelTerakhirDiperbarui => 'Last Updated';

  @override
  String get gantiPeranAktif => 'Switch Active Role';

  @override
  String get pengaturanAplikasi => 'App Settings';

  @override
  String get subtitlePengaturan => 'Theme, language, and preferences';

  @override
  String get labelPeranAkses => 'Roles & Access';

  @override
  String get labelPengaturanPreferensi => 'Settings & Preferences';

  @override
  String get sectionTampilanTema => 'Adjust the appearance';

  @override
  String get sectionBahasaLokalisasi => 'Choose the display language';

  @override
  String get sectionInformasiAplikasi => 'App Information';

  @override
  String get pilihSurveyor => 'Select petugas';

  @override
  String get labelIdLaporanDuplikatWajib => 'Duplicate Report ID (REQUIRED)';

  @override
  String get labelPilihSurveyorWajib => 'Select Petugas (REQUIRED)';

  @override
  String get labelAlasanWajib => 'Reason (REQUIRED)';

  @override
  String get hintMasukkanIdLaporanDuplikat => 'Enter duplicate report ID';

  @override
  String get hintBerikanAlasanKeputusan => 'Provide reason for this decision';

  @override
  String get laporanBerhasilDiverifikasi => 'Report successfully verified';

  @override
  String get laporanDitolak => 'Report rejected';

  @override
  String get mintaInformasi => 'Request Information';

  @override
  String gagalMemuat(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get belumAdaKasusVerifikasi => 'No cases pending verification.';

  @override
  String get permintaanInformasiTerkirim =>
      'Information request sent successfully';

  @override
  String get semuaNotifikasiDibaca => 'You marked all notifications as read.';

  @override
  String gagalMenandaiSemua(String error) {
    return 'Failed to mark all: $error';
  }

  @override
  String gagalMenandai(String error) {
    return 'Failed to mark: $error';
  }

  @override
  String get bacaSemua => 'Mark all read';

  @override
  String get buktiDitambahkanKeKasus => 'Evidence successfully added to case';

  @override
  String gagalMenambahkanBukti(String error) {
    return 'Failed to add evidence: $error';
  }

  @override
  String get kategoriLaporanTidakTersedia => 'Report category not available';

  @override
  String get laporanTersimpanAutoSync =>
      'SIGAP saved the report on this device. Check the sync center to confirm delivery.';

  @override
  String get gantiPeranPengguna => 'Switch User Role';

  @override
  String berhasilBeralihPeran(String role) {
    return 'Successfully switched to $role';
  }

  @override
  String get gagalBeralihPeran => 'Failed to switch role. Please try again.';

  @override
  String errorDenganPesan(String error) {
    return 'Error: $error';
  }

  @override
  String get mergeKasus => 'Merge Cases';

  @override
  String gagalUbahStatus(String error) {
    return 'Failed to change status: $error';
  }

  @override
  String get tugasDanProgres => 'Tasks & Progress';

  @override
  String get detailAudit => 'Audit Detail';

  @override
  String get fotoBukti => 'Evidence Photos';

  @override
  String get dokumen => 'Documents';

  @override
  String get lihatDiPetaLabel => 'View on Map';

  @override
  String get labelPenilaianAI => 'AI Assessment';

  @override
  String get izinDiperlukan => 'Permission Required';

  @override
  String get bukaPengaturan => 'Open Settings';

  @override
  String get aksesLokasi => 'Location Access';

  @override
  String get aksesKamera => 'Camera Access';

  @override
  String get konfigurasiBobotTersimpan =>
      'Priority weight configuration saved successfully';

  @override
  String get bobotPrioritas => 'Priority Weight';

  @override
  String get konfigurasiPrioritas => 'Priority Configuration';

  @override
  String get aturPrioritas => 'Set Priority';

  @override
  String get skorPrioritas => 'Priority Score: ';

  @override
  String get labelAlasanPerubahan => 'Reason for change';

  @override
  String get labelAlasanOpsional => 'Reason (optional)';

  @override
  String get labelIdKasusTarget => 'Target Case ID (REQUIRED)';

  @override
  String get assignKasus => 'Assign Case';

  @override
  String get labelIdUnitWajib => 'Unit ID (REQUIRED)';

  @override
  String get labelInstruksiOpsional => 'Instructions (optional)';

  @override
  String get aiRescanBerhasil => 'AI re-scan triggered successfully';

  @override
  String aiRescanGagal(String error) {
    return 'Failed to trigger re-scan: $error';
  }

  @override
  String get retryScan => 'Retry Scan';

  @override
  String get labelStatus => 'Status';

  @override
  String get labelConfidence => 'Confidence';

  @override
  String get labelResult => 'Result';

  @override
  String get semuaAksi => 'All Actions';

  @override
  String get createBuat => 'CREATE';

  @override
  String get updateUbah => 'UPDATE';

  @override
  String get deleteHapus => 'DELETE';

  @override
  String get approveSetujui => 'APPROVE';

  @override
  String get rejectTolak => 'REJECT';

  @override
  String get semuaTipeObjek => 'All Object Types';

  @override
  String get laporanReport => 'Report';

  @override
  String get penggunaUser => 'User';

  @override
  String get kategoriCategory => 'Category';

  @override
  String get unitKerja => 'Work Unit';

  @override
  String get csvFormat => 'CSV Format';

  @override
  String get jsonFormat => 'JSON Format';

  @override
  String get mengunduhAuditLog => 'Downloading audit log data...';

  @override
  String exportGagal(String error) {
    return 'Export failed: $error';
  }

  @override
  String get kondisiSebelumnya => 'Previous State (Before)';

  @override
  String get kondisiSesudahnya => 'After State (After)';

  @override
  String get metadataTambahan => 'Additional Metadata';

  @override
  String get labelAksi => 'Action';

  @override
  String get labelObjek => 'Object';

  @override
  String get labelActor => 'Actor';

  @override
  String get labelTanggal => 'Date';

  @override
  String get exportLabel => 'Export';

  @override
  String get supportingFactors => 'Supporting Factors';

  @override
  String get riskFactors => 'Risk Factors';

  @override
  String get labelKasusBaru => 'New cases';

  @override
  String get labelPerluVerifikasi => 'Needs verification';

  @override
  String get labelSlaTerlewat => 'Past the deadline';

  @override
  String get labelPrioritasTinggi => 'High priority';

  @override
  String get labelPerluKelengkapan => 'Needs completion';

  @override
  String get labelTotalAntrean => 'Total Queue';

  @override
  String get labelTepatWaktu => 'On Time';

  @override
  String get labelSedangDiproses => 'In Progress';

  @override
  String get labelSLATerlewatDashboard => 'SLA Overdue';

  @override
  String kasusBerisikoSLA(int count) {
    return '$count cases at SLA risk';
  }

  @override
  String get tingkatSinkronisasi => 'Sync Level';

  @override
  String get pusatSinkronisasi => 'Sync Center';

  @override
  String get petugasMenunggu => 'Officers Waiting';

  @override
  String get petugasLabel => 'Officers';

  @override
  String get totalAntreanLabel => 'Total Queue';

  @override
  String get selesaiLabel => 'Completed';

  @override
  String get totalLaporanLabel => 'Total Reports';

  @override
  String get totalKasusLabel => 'Total Cases';

  @override
  String get belumAdaRiwayatVerifikasi => 'No history yet';

  @override
  String get perjalananLaporanAkanDitampilkan =>
      'Report journey will be displayed here.';

  @override
  String langkahDari(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get fotoLabel => 'Photo';

  @override
  String get deskripsiLabel => 'Description';

  @override
  String get lokasiLabel => 'Location';

  @override
  String get dibuatLabel => 'Created';

  @override
  String get tindakanLabel => 'Action';

  @override
  String get timelineLabel => 'Timeline';

  @override
  String photoCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get menungguVerifikasi => 'Pending Verification';

  @override
  String get terverifikasi => 'Verified';

  @override
  String get sedangDitangani => 'Being Handled';

  @override
  String get perluLengkapi => 'Needs Completion';

  @override
  String get surveiLabel => 'Survey';

  @override
  String get tolakLabel => 'Reject';

  @override
  String get tugaskanPetugas => 'Assign Officer';

  @override
  String get gabungkan => 'Merge';

  @override
  String get tandaiSelesai => 'Mark Complete';

  @override
  String get labelSeverity => 'Severity';

  @override
  String get labelScore => 'Score';

  @override
  String get petugasLabelA => 'Officer';

  @override
  String get clarifikasiLabel => 'Clarification';

  @override
  String get kunjungiLabel => 'Visit';

  @override
  String get terimaLabel => 'Accept';

  @override
  String get adminDaerah => 'Regional Admin';

  @override
  String get tugasDiprosesSurveyorLain =>
      'Task is being processed by another petugas';

  @override
  String get verifikatorMemintaInfo =>
      'The verifier requested additional information to complete this report.';

  @override
  String get ringkasanOperasionalDaerah => 'Regional Operational Summary';

  @override
  String get dataPenangananKasusDaerah => 'Regional case handling data';

  @override
  String get apaYangHarusDitanganiHariIni => 'What needs to be handled today?';

  @override
  String get petaRingkasKasus => 'Case summary map';

  @override
  String get bukaPeta => 'Open Map →';

  @override
  String get lihatSemuaKasusDiPeta => 'See all cases on map';

  @override
  String get dashboardAuditor => 'Auditor Dashboard';

  @override
  String get auditIntegrityMonitoring => 'Audit & Integrity Monitoring';

  @override
  String get lihatLogAktivitas => 'View Activity Log →';

  @override
  String get gagalMemuatStatistik => 'Failed to load statistics';

  @override
  String get gagalMemuatAntrean => 'Failed to load queue';

  @override
  String get gagalMemuatTren => 'Failed to load trend';

  @override
  String get gagalMemuatKasusKritis => 'Failed to load critical cases';

  @override
  String get gagalMemuatAnalitik => 'Failed to load analytics';

  @override
  String get belumAdaKonfigurasiSLA =>
      'No complaint handling time limit configuration yet.';

  @override
  String get tidakAdaNotifikasi => 'You have no notifications yet';

  @override
  String get pemberitahuanTerkait =>
      'SIGAP will show your report and task updates here. Tap a notification to open the related report when a link is available.';

  @override
  String get gagalMemuatNotifikasi =>
      'SIGAP could not load notifications. Check your connection and try again.';

  @override
  String get modeGelap => 'Dark Mode';

  @override
  String get modeGelapSubtitle =>
      'Use a dark background when reading the app in low light.';

  @override
  String get bahasaAplikasi => 'App Language';

  @override
  String get pilihBahasa => 'Select Language';

  @override
  String get peranSaatIni => 'Current Role';

  @override
  String get akunHanyaSatuPeran =>
      'Your account currently has only one active role. Contact the Regional Administrator if you need access to additional roles.';

  @override
  String get aktif => 'ACTIVE';

  @override
  String get peranTersedia => 'Roles Available for This Account';

  @override
  String get peranAktifSaatIni => 'Current active role';

  @override
  String get tapUntukMengaktifkan => 'Tap to activate';

  @override
  String get algoritmaPenilaianPrioritas => 'Priority Assessment Algorithm';

  @override
  String get aturPersentaseBobot =>
      'Set the weight percentage of each factor to calculate automatic priority scores for incoming reports.';

  @override
  String get statusSLAAktif => 'SLA Status Active';

  @override
  String get slaDinonaktifkan =>
      'If deactivated, delay warnings are not counted';

  @override
  String get tentukanBatasWaktuSLA =>
      'Set the standard handling time limit (SLA) for this report category.';

  @override
  String get belumPunyaAkun => 'Don\'t have an account?';

  @override
  String get akunDemo => 'Demo Account';

  @override
  String get loginGagal => 'Login failed';

  @override
  String get sistemInformasiGeospasial =>
      'Geospatial Information System\n& Report Handling';

  @override
  String get gunakanAkun =>
      'Sign in to submit and follow reports, or to open your field assignments.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get emailKosong => 'Enter your email address.';

  @override
  String get emailTidakValid => 'Check the format of your email address.';

  @override
  String get kataSandi => 'Password';

  @override
  String get kataSandiKosong => 'Enter your password.';

  @override
  String get kataSandiMinimal6 => 'Password must be at least 6 characters';

  @override
  String get registrasiGagal => 'Registration failed';

  @override
  String get tidakDapatTerhubung => 'Cannot connect to server';

  @override
  String get daftarAkun => 'Register Account';

  @override
  String get buatAkunBaru =>
      'Create a resident account to submit reports and follow their progress.';

  @override
  String get namaLengkap => 'Full Name';

  @override
  String get namaLengkapHint => 'Your full name';

  @override
  String get namaKosong => 'Enter your name.';

  @override
  String get namaMinimal2 => 'Name must be at least 2 characters';

  @override
  String get kataSandiMinimal8 => 'Password must be at least 8 characters';

  @override
  String get konfirmasiKataSandi => 'Confirm Password';

  @override
  String get ulangiKataSandi => 'Repeat password';

  @override
  String get kataSandiTidakCocok => 'Enter the same password again.';

  @override
  String get sudahPunyaAkun => 'Already have an account?';

  @override
  String get minimal8Karakter => 'Minimum 8 characters';

  @override
  String get gagalMemuatKasusTerdekat => 'Failed to load nearest cases';

  @override
  String get gagalMemuatLaporan => 'Failed to load reports';

  @override
  String get memuat => 'Loading...';

  @override
  String get semuaTugasSudahDiunduh => 'All tasks already downloaded';

  @override
  String get hariLalu => 'days ago';

  @override
  String get mingguLalu => 'weeks ago';

  @override
  String get jamLalu => 'hours ago';

  @override
  String get jalanRusak => 'Road Damage';

  @override
  String get jembatan => 'Bridge';

  @override
  String get drainase => 'Drainage';

  @override
  String get fasilitasUmum => 'Public Facilities';

  @override
  String get gagalMemuatPeta => 'Failed to load map';

  @override
  String get mendukung => 'supporting';

  @override
  String get tapUntukBukaKamera => 'Tap to take an evidence photo';

  @override
  String get lokasiTerdeteksi => 'Location Detected';

  @override
  String get ambilLokasiGps => 'Get GPS Location';

  @override
  String get tapUntukMendapatkanLokasi => 'Tap to get current location';

  @override
  String kasusSerupa(int count) {
    return '$count Similar Cases';
  }

  @override
  String get tidakDapatAksesGps =>
      'Cannot access GPS. Select location manually on map.';

  @override
  String laporanTersimpanDi(String address) {
    return 'Report saved at $address';
  }

  @override
  String get laporanTersimpanTerkirim => 'SIGAP received your report.';

  @override
  String laporanAnonimTersimpanDi(String address) {
    return 'Anonymous report saved at $address';
  }

  @override
  String laporanAnonimTersimpanId(String id) {
    return 'Anonymous report saved: $id';
  }

  @override
  String tersimpanPada(String time) {
    return 'Saved $time';
  }

  @override
  String get orang => 'people';

  @override
  String get jumlahPerkiraanTerdampak =>
      'Estimated number of residents affected by this incident';

  @override
  String get seberapaRentan => 'How vulnerable is the local community?';

  @override
  String get pilihJenisDampak => 'Select the type of impact:';

  @override
  String get keselamatan => 'Safety';

  @override
  String get layananSekolah => 'School services';

  @override
  String get ekonomi => 'Economy';

  @override
  String get lingkungan => 'Environment';

  @override
  String get bagianDariKasus => 'Part of case';

  @override
  String get lihatLabel => 'View';

  @override
  String get perjalananLaporanHeader => 'REPORT JOURNEY';

  @override
  String get privasiInfo =>
      'Your identity & precise location are only visible to related officers. Public sees generalized location.';

  @override
  String get gagalUrlUpload => 'Failed to get photo upload URL';

  @override
  String get tambahkanFotoDeskripsi =>
      'Add a photo that clarifies the reported condition. Use the description to point out what staff should check.';

  @override
  String get deskripsiOpsional => 'Description (optional)';

  @override
  String get jelaskanInfoTambahan =>
      'Describe additional information you want to provide...';

  @override
  String alasanMinimalKarakter(int count) {
    return 'Reason must be at least $count characters';
  }

  @override
  String gagalAjukanSanggahan(String error) {
    return 'Failed to submit objection: $error';
  }

  @override
  String get ajukanKeberatan =>
      'Submit an objection to your report rejection decision.';

  @override
  String get alasanSanggahan => 'Objection Reason';

  @override
  String minimalKarakter(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get jelaskanAlasanKeberatan =>
      'Describe what this additional evidence shows…';

  @override
  String get buktiFotoOpsional => 'Photo Evidence (optional)';

  @override
  String get tambahkanFotoBukti =>
      'Add photo as supporting evidence for your objection';

  @override
  String get lewatI => 'Skip';

  @override
  String get izinkan => 'Allow';

  @override
  String izinDiperlukanPesan(String title) {
    return 'Open settings to allow $title, then return to SIGAP.';
  }

  @override
  String get berdasarkanStatus => 'View handling stages';

  @override
  String get berdasarkanKategori => 'View report categories';

  @override
  String get aksesLokasiBody =>
      'Allow SIGAP to read your device location to show nearby reports and help you choose a report location. Check the point before sending.';

  @override
  String get aksesKameraBody =>
      'Allow camera access if you want to take evidence photos in SIGAP. You can also choose a photo from your device.';

  @override
  String get notifikasiBody =>
      'Allow SIGAP to show report and task updates on this device. You can change the permission in settings.';

  @override
  String get tambahkanBukti => 'Add Evidence';

  @override
  String gagalMengambilFoto(String error) {
    return 'Failed to pick photo: $error';
  }

  @override
  String get gagalMemuatData => 'Failed to load data';

  @override
  String get keputusanBerhasilDikirim => 'Decision sent successfully';

  @override
  String get assessmentTidakTersedia => 'Assessment not available';

  @override
  String get tidakAdaDokumen => 'No documents';

  @override
  String get menungguKlaimPersonel => 'Awaiting personnel claim';

  @override
  String get informasiYangDiperlukan => 'Required information';

  @override
  String get umurBacklogKasus => 'Case backlog age';

  @override
  String get dataTidakTersedia => 'Data not available';

  @override
  String get distribusiStatus => 'Status Distribution';

  @override
  String get distribusiKategori => 'Category Distribution';

  @override
  String get dataKategoriTidakTersedia => 'Category data not available';

  @override
  String get semuaPetugasAktif => 'All officers active';

  @override
  String get terjadiKesalahan => 'An error occurred. Please try again.';

  @override
  String get koneksiTimeout => 'Connection timeout. Please try again.';

  @override
  String get tidakAdaKoneksiInternet => 'No internet connection.';

  @override
  String get permintaanDibatalkan => 'Request cancelled.';

  @override
  String get emailAtauPasswordSalah => 'Invalid email or password.';

  @override
  String get sesiHabis => 'Session expired. Please login again.';

  @override
  String get andaTidakMemilikiAkses => 'You don\'t have access.';

  @override
  String get dataTidakDitemukan => 'Data not found.';

  @override
  String get dataTidakValid => 'Invalid data. Please check your input.';

  @override
  String get serverSedangBermasalah =>
      'Server is having issues. Please try again later.';

  @override
  String get terlaluBanyakPermintaan =>
      'Too many requests. Please try again later.';

  @override
  String get dataSudahAdaAtauKonflik => 'Data already exists or conflict.';

  @override
  String get serverTidakTersedia =>
      'Server unavailable. Please try again later.';

  @override
  String terjadiKesalahanDenganCode(int statusCode) {
    return 'An error occurred (code: $statusCode).';
  }

  @override
  String apiError(int statusCode) {
    return 'API Error: $statusCode';
  }

  @override
  String requestTimeoutPada(String endpoint) {
    return 'Request timeout on $endpoint';
  }

  @override
  String get minimal10KarakterValidasi => 'minimum 10 characters';

  @override
  String get tidakDitemukan => 'Not found';

  @override
  String get tidakBolehKosong => 'cannot be empty';

  @override
  String get formatEmailTidakValid => 'invalid email format';

  @override
  String get terlaluPanjang => 'too long';

  @override
  String get terlaluPendek => 'too short';

  @override
  String get harus => 'must';

  @override
  String get gagalMendekodeGambar => 'Failed to decode image for EXIF removal';

  @override
  String get menungguVerifikasiLabel => 'Waiting for verification';

  @override
  String get terverifikasiLabel => 'Verified';

  @override
  String get sedangDitanganiLabel => 'Being handled';

  @override
  String get perluKelengkapanLabel => 'Needs completion';

  @override
  String get slaTerlewatLabel => 'SLA overdue';

  @override
  String get tersimpanDiPerangkatLabel => 'Saved on device';

  @override
  String get laporanDiterimaLabel => 'Report accepted';

  @override
  String get sedangDiperiksaLabel => 'Being checked';

  @override
  String get perluDilengkapiLabel => 'Needs to be completed';

  @override
  String get perluTindakanAndaLabel => 'Needs your action';

  @override
  String get draftLabel => 'Draft';

  @override
  String get digabungLabel => 'Merged';

  @override
  String get dipisahLabel => 'Split';

  @override
  String get dalamReviewLabel => 'Under Review';

  @override
  String get unknownLabel => 'Information not recorded';

  @override
  String get laporanPertamaDiterima => 'First report received';

  @override
  String get kasusDibuatDariKonsolidasi => 'Case created from consolidation';

  @override
  String get laporanDigabung => 'Report merged';

  @override
  String get menungguVerifikasiManual => 'Waiting for manual verification';

  @override
  String get laporanNav => 'Reports';

  @override
  String get sinkronNav => 'Sync';

  @override
  String get riwayatNav => 'History';

  @override
  String get akunNav => 'Account';

  @override
  String get buatLaporanFAB => 'Create report';

  @override
  String get izinkanLokasiDitolakSnack => 'Location permission denied';

  @override
  String gagalCaptureGPS(String error) {
    return 'SIGAP could not read the device location. Check location permissions and try again. Details: $error';
  }

  @override
  String get maksimal5Foto => 'Maximum 5 photos';

  @override
  String tambahFoto(int count, int max) {
    return 'Add photo ($count/$max)';
  }

  @override
  String get formSurveiTitle => 'Record survey findings';

  @override
  String get kembaliKeDaftarTugasBtn => 'Back to Task List';

  @override
  String get fotoPerSudut => 'Take a photo from each angle';

  @override
  String get formSurveiHeader => 'Record conditions on site';

  @override
  String get gpsBelumTertangkap => 'You have not recorded a location';

  @override
  String get tidakDitemukanDiLokasi =>
      'I did not find the issue at this location';

  @override
  String get ringkasanTab => 'Summary';

  @override
  String get buktiLaporanTab => 'Evidence & Reports';

  @override
  String get verifikasiTab => 'Verification';

  @override
  String get tugasProgresTab => 'Tasks & Progress';

  @override
  String get riwayatAuditTab => 'Audit History';

  @override
  String aksiGunakanPanelVerifikasi(String label) {
    return 'Action \"$label\" - use verification panel';
  }

  @override
  String bukaTabVerifikasi(String label) {
    return 'Open Verification tab for action \"$label\"';
  }

  @override
  String get statusKasus => 'Case Status';

  @override
  String get daftarTugasProgres =>
      'Task list and handling progress will be displayed here.';

  @override
  String get riwayatAuditLabel => 'Audit History';

  @override
  String get detailAuditTitle => 'Audit Detail';

  @override
  String get detailAuditDesc =>
      'Complete audit chain details will be displayed here.';

  @override
  String get belumAdaRiwayatAudit => 'No audit history yet';

  @override
  String get transisiStatusTidakValid =>
      'Invalid status transition. Report may have been processed.';

  @override
  String gagalMengirimKeputusan(String error) {
    return 'Failed to send decision: $error';
  }

  @override
  String gagalMemuatError(String error) {
    return 'Failed to load: $error';
  }

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get andaTidakAksesVerifikasi =>
      'You don\'t have access to verify this case.';

  @override
  String get andaTidakAksesTugas =>
      'You don\'t have access to view case tasks.';

  @override
  String get andaTidakAksesAudit =>
      'You don\'t have access to view audit history.';

  @override
  String get tidakAdaTugasTitle => 'No Tasks';

  @override
  String get tugasPenangananMuncul =>
      'Handling tasks for this case will appear here.';

  @override
  String get tidakAdaDeskripsi => 'No description.';

  @override
  String koordinatLabel(String lat, String lng) {
    return 'Coordinates: $lat, $lng';
  }

  @override
  String prioritasLabel(String value) {
    return 'Priority: $value';
  }

  @override
  String get kembaliKeLaporan => 'Back to Report';

  @override
  String get batalBtn => 'Cancel';

  @override
  String get idLaporanLabel => 'Report number';

  @override
  String get apaItuSanggahan => 'What is an Objection?';

  @override
  String get sanggahanAdalah =>
      'An objection is your way to file a grievance against a rejection decision.';

  @override
  String get alasanSanggahanLabel => 'Objection Reason';

  @override
  String get wajibLabel => 'REQUIRED';

  @override
  String karakterMinimum(int current, int minimum) {
    return '$current / $minimum characters minimum';
  }

  @override
  String get validLabel => 'Valid';

  @override
  String get ajukanSanggahanBtn => 'Submit Objection';

  @override
  String gagalAjukanSanggahanError(String error) {
    return 'Failed to submit objection: $error';
  }

  @override
  String get sanggahanBerhasil => 'You have submitted your appeal';

  @override
  String sanggahanBerhasilDesc(String reportId) {
    return 'SIGAP received your appeal for report $reportId. Follow its progress in report details; submitting an appeal does not change the previous decision.';
  }

  @override
  String get filterAuditLog => 'Filter Audit Log';

  @override
  String get idUserNamaActor => 'User ID / Name (Actor)';

  @override
  String get idObjekResourceId => 'Object ID (Resource ID)';

  @override
  String get aksiAction => 'Action';

  @override
  String get tipeObjekResourceType => 'Object Type (Resource Type)';

  @override
  String get filterAktif => 'Active Filter: ';

  @override
  String aksiFilter(String value) {
    return 'Action: $value';
  }

  @override
  String objekFilter(String value) {
    return 'Object: $value';
  }

  @override
  String actorFilter(String value) {
    return 'Actor: $value';
  }

  @override
  String get tanggalTerpilih => 'Date: Selected';

  @override
  String detailPerubahanLabel(String action) {
    return 'Change Detail: $action';
  }

  @override
  String get gagalMemuatAuditLog => 'Failed to Load Audit Log';

  @override
  String get tidakAdaDataAuditLog => 'No Audit Log Data';

  @override
  String get tidakDitemukanRiwayatLog =>
      'No log history found with current filter criteria.';

  @override
  String get belumAdaAktivitasTercatat =>
      'No activity recorded in audit log yet.';

  @override
  String get lihatDetailPerubahanDiff => 'View change detail (diff)';

  @override
  String get kosongTidakAdaData => '(Empty / No data)';

  @override
  String get wargaRole => 'Citizen';

  @override
  String get petugasRole => 'Officer';

  @override
  String get adminRole => 'Admin';

  @override
  String get tidakAdaTugasSurvei => 'No Survey Tasks';

  @override
  String get belumAdaTugas => 'No Tasks Yet';

  @override
  String get detailTugasSurvei => 'Survey Task Detail';

  @override
  String get detailTugasPetugas => 'Officer Task Detail';

  @override
  String get gagalMemuatDetailTugas => 'Failed to Load Task Detail';

  @override
  String get gagalMemuatTugasTitle => 'Failed to Load Tasks';

  @override
  String get urutkanLabel => 'Sort: ';

  @override
  String get tugasHariIni => 'Today\'s Tasks';

  @override
  String get semuaTersinkronStatus => 'All synchronized';

  @override
  String get tidakAdaDataMenungguSinkron => 'No data waiting to sync';

  @override
  String get gagalDikirimLabel => 'Failed to send';

  @override
  String get menungguLabel => 'Waiting';

  @override
  String get gagalLabel => 'Failed';

  @override
  String get kasusKritisTitle => 'Critical Cases';

  @override
  String get tidakAdaKasusKritis => 'No critical cases';

  @override
  String get gagalMemuatPetaError => 'Failed to load map';

  @override
  String statusMarker(String status) {
    return 'Status: $status';
  }

  @override
  String get kategoriSection => 'Category';

  @override
  String get statusSection => 'Status';

  @override
  String get waktuSection => 'Time';

  @override
  String get pengaturanTooltip => 'Settings';

  @override
  String get wargaDefault => 'Citizen';

  @override
  String get apakahYakinKeluar =>
      'Are you sure you want to log out from this account?';

  @override
  String get bahasaIndonesiaLabel => 'Bahasa Indonesia';

  @override
  String get statusServer => 'Server Status';

  @override
  String get onlineTersambung => 'Online (Connected)';

  @override
  String get cobaLagiBtn => 'Try Again';

  @override
  String get aksesDitolakTitle => 'Access Denied';

  @override
  String get tutupBtn => 'Close';

  @override
  String get tentangPrivasi => 'About Privacy';

  @override
  String get privasiInfoBody =>
      'Your identity and precise location are only visible to related officers. Public only sees generalized location.';

  @override
  String get identitasPublik => 'My identity is public';

  @override
  String get prioritasRendah => 'Low';

  @override
  String get prioritasTinggi => 'High';

  @override
  String get prioritasDiubah => 'Priority changed';

  @override
  String get rendahLabel => 'Low';

  @override
  String get tinggiLabel => 'High';

  @override
  String get siapOfflineBadge => 'Ready for offline';

  @override
  String get unduhUntukOffline => 'Download for offline';

  @override
  String get prioritasTinggiCard => 'High priority';

  @override
  String get prioritasSedangCard => 'Medium priority';

  @override
  String get prioritasNormalCard => 'Normal priority';

  @override
  String get prioritasRendahCard => 'Low priority';

  @override
  String get tugasHariIniTitle => 'Today\'s Tasks';

  @override
  String get umurBacklogTitle => 'Case backlog age';

  @override
  String get unduhBatchBtn => 'Download batch';

  @override
  String get kasusKritisDefault => 'Critical cases';

  @override
  String get kasusTerdekatTitle => 'Nearest Case';

  @override
  String get lihatPetaAction => 'View map';

  @override
  String get sedangDitanganiStatus => 'Being handled';

  @override
  String get terverifikasiStatus => 'Verified';

  @override
  String get lokasiGPS => 'GPS Location';

  @override
  String get catatanLapangan => 'Field notes';

  @override
  String get tambahkanCatatan => 'Add notes...';

  @override
  String get batasWaktuBelumDipilih => 'Deadline: (not selected)';

  @override
  String batasWaktuLabel(String time) {
    return 'Deadline: $time';
  }

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get simpanDanSinkronkanNantiBtn => 'Save and sync later';

  @override
  String get tidakAdaKoneksiAntrean =>
      'No connection - report will enter queue.';

  @override
  String get tambahkanBuktiKeKasus => 'Add evidence to this case';

  @override
  String get buatTerpisah => 'Create separate';

  @override
  String get lanjutKeReviewHasilSurvei => 'Continue to survey results review';

  @override
  String get mintaClarifikasiBtn => 'Request Clarification';

  @override
  String get terimaTugasBtn => 'Accept Task';

  @override
  String get sinkronkanSekarang => 'Sync Now';

  @override
  String get sinkronkanSekarangSemantics => 'Sync now';

  @override
  String get petaAreaBuktiDiunduh => 'Map area + downloaded evidence';

  @override
  String get duplicateCandidates => 'Duplicate Candidates';

  @override
  String get menungguVerifikasiSnackBar => 'Waiting for verification';

  @override
  String get terverifikasiSnackBar => 'Verified';

  @override
  String get sedangDitanganiSnackBar => 'Being handled';

  @override
  String get perluKelengkapanSnackBar => 'Needs completion';

  @override
  String get slaTerlewatSnackBar => 'SLA overdue';

  @override
  String get submittedLabel => 'Submitted';

  @override
  String get underReviewLabel => 'Under Review';

  @override
  String get inProgressLabel => 'In Progress';

  @override
  String get resolvedLabel => 'Resolved';

  @override
  String get rejectedLabel => 'Rejected';

  @override
  String get verifiedLabel => 'Verified';

  @override
  String get kualitasData => 'Data Quality';

  @override
  String get tingkatSinkronisasiLabel => 'Sync Level';

  @override
  String get surveyorMenungguLabel => 'Petugas Waiting';

  @override
  String get risikoSLA => 'SLA Risk';

  @override
  String get semuaKasusOnTrack => 'All cases on track';

  @override
  String get pendahLabel => 'Pending';

  @override
  String get sinkronisasiBerhasil => 'Sync Successful';

  @override
  String get dataBerhasilDisinkronkan => 'Data successfully synced to server';

  @override
  String get sinkronisasiGagal => 'Sync Failed';

  @override
  String get gagalMenyinkronkanData => 'Failed to sync data. Please try again.';

  @override
  String get itemGagalDisinkronkan => 'Item failed to sync';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get exportCSVGagal => 'CSV export failed:';

  @override
  String get exportGeoJSONGagal => 'GeoJSON export failed:';

  @override
  String get exportPDFGagal => 'PDF export failed:';

  @override
  String get emptyGeoJSON => 'Empty GeoJSON';

  @override
  String get sigapMobile => 'SIGAP Mobile';

  @override
  String get sistemInformasiGerakAduan =>
      'Geospatial Information System & Public Complaint Handling';

  @override
  String get versiAplikasi => 'v1.0.0';

  @override
  String get batalkanTugasTitle => 'Reject Task';

  @override
  String get alasanPenolakanLabel => 'Rejection reason';

  @override
  String get masukkanAlasanHint => 'Enter reason...';

  @override
  String get mintaClarifikasiTitle => 'Request Clarification';

  @override
  String get pertanyaanKlarifikasiLabel => 'Question / clarification';

  @override
  String get tulisPertanyaanHint => 'Type your question...';

  @override
  String get kondisiAktual => 'Select the condition you observed';

  @override
  String get rekomendasiHasil => 'Recommend the next step';

  @override
  String get ambilGPS => 'Record device location';

  @override
  String get pilihPeranKonteks =>
      'Select a role to switch work context. Menu, data flow, and access permissions will be automatically adjusted.';

  @override
  String get kirimLaporanPublik =>
      'Submit public complaint reports and monitor completion status.';

  @override
  String get ringkasanEksekutif =>
      'Executive summary, verification trend analysis, and regional statistics.';

  @override
  String get gagalMemuatAssessment => 'Failed to Load Assessment';

  @override
  String get belumAdaAssessmentAI => 'No AI Assessment Yet';

  @override
  String get formatExportTitle => 'Export Format';

  @override
  String get riwayatAuditImmutable =>
      'Audit history is immutable and cannot be modified. ';

  @override
  String get kategoriColon => 'Category:';

  @override
  String get deskripsiColon => 'Description:';

  @override
  String get fotoColon => 'Photo:';

  @override
  String get buktiFotoDariPelapor => 'Photo evidence of damage from reporter';

  @override
  String get koordinatColon => 'Coordinates:';

  @override
  String get lokasiTepatDiPeta => 'Exact location on map';

  @override
  String get tanggalColon => 'Date:';

  @override
  String get kapanLaporanDibuat => 'When the report was created';

  @override
  String get statusLaporan => 'Report Status';

  @override
  String get laporanBaru => 'New report';

  @override
  String get perluTindakanStatus => 'Needs Action';

  @override
  String get sedangDiprosesStatus => 'In Progress';

  @override
  String get selesaiStatus => 'Done';

  @override
  String get ditolakStatus => 'Rejected';

  @override
  String get keteranganPrivasiTooltip =>
      'If active, your name is visible to public. Location remains generalized.';

  @override
  String get identitasLokasiPrivasi =>
      'Your identity and precise location are only visible to related officers. Public only sees generalized location.';

  @override
  String get gpsBadge => 'GPS';

  @override
  String get maks5FotoFormat =>
      'Max 5 photos, JPG/PNG format. GPS from EXIF will be used if available.';

  @override
  String get jamSuffix => 'Hours';

  @override
  String get aktifStatus => 'Active';

  @override
  String get nonaktifStatus => 'Inactive';

  @override
  String targetJam(int hours) {
    return 'Target: $hours hours';
  }

  @override
  String slugPrefix(String value) {
    return 'Slug: $value';
  }

  @override
  String get latihanVerifikasiLaporan => 'Report Verification Training';

  @override
  String get apaItuSIGAP => 'What is SIGAP?';

  @override
  String get tujuanSIGAP => 'SIGAP Purpose';

  @override
  String get caraMemverifikasiLaporan => 'How to Verify Reports';

  @override
  String get terimaTautanVerifikasi => 'Receive Verification Link';

  @override
  String get bukaTautan => 'Open Link';

  @override
  String get periksaKondisiLapangan => 'Check Field Conditions';

  @override
  String get berikanKeputusan => 'Make a Decision';

  @override
  String get kirimVerifikasiTitle => 'Submit Verification';

  @override
  String get klikTombolKirimVerifikasi =>
      'Click the \'Submit Verification\' button to send your decision to the system.';

  @override
  String get memahamiDashboardSIGAP => 'Understanding SIGAP Dashboard';

  @override
  String get dashboardMenampilkanLaporan =>
      'The SIGAP Dashboard displays all incoming damage reports.';

  @override
  String get bestPractice => 'Best Practice';

  @override
  String get lakukan => 'Do';

  @override
  String get verifikasiDalam1x24Jam => 'Verify reports within 1x24 hours';

  @override
  String get hindari => 'Don\'t';

  @override
  String get pertanyaanUmum => 'Frequently Asked Questions';

  @override
  String get statusDikonfirmasi => 'Confirmed';

  @override
  String get statusDitolakRT => 'Rejected';

  @override
  String get laporanTidakValid => 'Report is not valid';

  @override
  String get berikanAlasanJelas => 'Provide a clear reason';

  @override
  String get simpanKonfigurasiBtn => 'Save Configuration';

  @override
  String get editSLATooltip => 'Edit SLA';

  @override
  String get segarkanTooltip => 'Refresh';

  @override
  String get antreanNav => 'Queue';

  @override
  String get exportNav => 'Export';

  @override
  String get analitikNav => 'Analytics';

  @override
  String get dashboardEksekutif => 'Executive Dashboard';

  @override
  String get masukkanPertanyaanInformasiHint =>
      'Enter the question or information needed...';

  @override
  String diajukanPada(String date) {
    return 'Submitted: $date';
  }

  @override
  String olehPelaku(String userId) {
    return 'by: $userId';
  }

  @override
  String get verifikasiLaporan => 'Verify Reports';

  @override
  String get panduanLengkapRTRW =>
      'Complete guide for RT and RW officials in using the SIGAP system';

  @override
  String get deskripsiSIGAP =>
      'SIGAP (Geospatial Information System & Village Report Handling) is a digital platform for mapping and monitoring village development. This system helps record, track, and resolve infrastructure damage reports in your area.';

  @override
  String get memetakanKerusakan => 'Mapping infrastructure damage';

  @override
  String get mempercepatPerbaikan => 'Accelerating repair process';

  @override
  String get transparansiLaporan => 'Transparency of community reports';

  @override
  String get koordinasiPemerintah => 'Coordination between government levels';

  @override
  String get memverifikasiLaporan => 'Verifying damage reports';

  @override
  String get memberikanKonfirmasi => 'Providing field confirmation';

  @override
  String get melaporkanKerusakanBaru => 'Reporting new damage';

  @override
  String get memantauStatusPerbaikan => 'Monitoring repair status';

  @override
  String get deskripsiTerimaTautan =>
      'You will receive a verification link via SMS or WhatsApp from the SIGAP system. The link contains a unique token to access the report.';

  @override
  String get deskripsiBukaTautan =>
      'Click the link sent to you. You will be redirected to the SIGAP verification page.';

  @override
  String get deskripsiPeriksaKondisi =>
      'Visit the location mentioned in the report. Check if the damage really exists and note the actual conditions.';

  @override
  String get deskripsiBerikanKeputusan =>
      'Select \'Confirmed\' if the damage really exists, or \'Rejected\' if the report is not valid. Provide a clear reason.';

  @override
  String get deskripsiKirimVerifikasi =>
      'Click the \'Submit Verification\' button to send your decision to the system.';

  @override
  String get deskripsiMemahamiDashboard =>
      'The SIGAP Dashboard displays all incoming damage reports. Here are the main elements you need to know:';

  @override
  String get datangLangsungKeLokasi => 'Visit the location in person';

  @override
  String get berikanAlasanDetail => 'Provide detailed reasons';

  @override
  String get dokumentasikanDenganFoto => 'Document with photos';

  @override
  String get laporkanJikaKendala => 'Report if there are obstacles';

  @override
  String get memverifikasiTanpaKeLokasi =>
      'Verifying without visiting location';

  @override
  String get memberikanAlasanKosong => 'Giving empty reasons';

  @override
  String get menundaVerifikasi => 'Delaying verification too long';

  @override
  String get menolakTanpaAlasan => 'Rejecting without clear reason';

  @override
  String get mengabaikanLaporan => 'Ignoring community reports';

  @override
  String get faqLokasiSulitDiakses =>
      'What if the location is difficult to access?';

  @override
  String get faqLokasiSulitDiaksesJawab =>
      'Try to verify from the nearest possible point. If it really cannot be accessed, provide a reason in the system and ask for help from neighbors or nearby residents for documentation.';

  @override
  String get faqLaporanTidakJelasPertanyaan =>
      'What should be done if the report is unclear?';

  @override
  String get faqLaporanTidakJelasJawab =>
      'Contact the reporter through the listed number to request clarification. If unreachable, verify based on available information and note the ambiguity.';

  @override
  String get faqWaktuVerifikasiPertanyaan =>
      'How long is the verification time?';

  @override
  String get faqWaktuVerifikasiJawab =>
      'Ideally, verification should be done within 1x24 hours after the report is received. However, if there are obstacles, immediately contact the regional admin.';

  @override
  String get faqTidakSetujuPertanyaan =>
      'What if I disagree with the officer\'s decision?';

  @override
  String get faqTidakSetujuJawab =>
      'Every decision is recorded in the system. If there are objections, please contact the regional admin or submit through the available comment feature.';

  @override
  String get siapMemulai => 'Ready to Start?';

  @override
  String get aksesMenuVerifikasi =>
      'Access the Report Verification menu to process damage reports from the community.';

  @override
  String get pelatihanSelesai => 'Training Complete';

  @override
  String get dalamPenanganan => 'Under handling';

  @override
  String get sudahDiperbaiki => 'Already repaired';

  @override
  String get informasiLaporan => 'Report Information';

  @override
  String get sanggahanDeskripsiLengkap =>
      'Submit an appeal if you have reasons or evidence for reviewing the report decision. Explain which part you question and what staff should check again.';

  @override
  String jelaskanAlasanSanggahanHint(int count) {
    return 'Explain your objection reason in detail...\n\nMinimum $count characters.';
  }

  @override
  String get rentangTanggalSemua => 'Date Range: (All)';

  @override
  String olehLabel(String actor) {
    return 'By: $actor';
  }

  @override
  String tugasCount(int count) {
    return '$count Tasks';
  }

  @override
  String ditugaskanPada(String date) {
    return 'Assigned: $date';
  }

  @override
  String entriAuditCount(int count) {
    return '$count Audit Entries';
  }

  @override
  String get riwayatAuditInfo =>
      'Audit history is immutable and cannot be modified. All actions on this case are recorded for audit purposes.';

  @override
  String get semuaTindakanTercatatDiSini =>
      'All actions on this case will be recorded here.';

  @override
  String resourceLabel(String resource) {
    return 'Resource: $resource';
  }

  @override
  String gpsBerhasilDitangkap(String lat, String lng) {
    return 'The device recorded $lat, $lng. Check that this matches the survey site.';
  }

  @override
  String gagalMemilihGambar(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get ringan => 'Light';

  @override
  String get kritis => 'Critical';

  @override
  String get validPerluTindakLanjut => 'The issue still needs action';

  @override
  String kondisiColonLabel(String value) {
    return 'Condition: $value';
  }

  @override
  String rekomendasiColonLabel(String value) {
    return 'Recommendation: $value';
  }

  @override
  String get dataSurveiTersimpanLokal =>
      'SIGAP saved the survey on this device. Open the sync center when internet returns to check its delivery.';

  @override
  String get dataSurveiTersimpanDiproses =>
      'SIGAP has received your survey. The admin will review your notes and photos before deciding the next steps.';

  @override
  String get hintCatatanLapangan =>
      'Describe what you observed, the measurements you took, and any action you carried out.';

  @override
  String get labelOffline => 'offline';

  @override
  String get tambahFotoLabel => 'Add photo';

  @override
  String get ketukUntukMenangkapGps =>
      'Record your location at the inspection site. The device position does not replace notes about conditions on site.';

  @override
  String get depan => 'Front';

  @override
  String get samping => 'Side';

  @override
  String get atas => 'Top';

  @override
  String fotoCountDari(int count, int total) {
    return '$count of $total';
  }

  @override
  String infoSerupa(String distance, int similarity, int count) {
    return '$distance · $similarity% similarity · $count reports';
  }

  @override
  String get tidakDapatTerhubungKeServer => 'Cannot connect to server.';

  @override
  String get errorTidakDikenal => 'Unknown error';

  @override
  String get gagalRetryLoop => 'Unexpected retry loop exit';

  @override
  String get gagalMemuatLaporanPublik => 'Failed to fetch public reports';

  @override
  String get gagalMemuatKasusPublik => 'Failed to fetch public case';

  @override
  String get gagalMemuatStatistikPublik => 'Failed to fetch public stats';

  @override
  String get gagalMemuatMetadataBagikan => 'Failed to fetch share metadata';

  @override
  String fileFotoTidakDitemukan(String path) {
    return 'Photo file not found: $path';
  }

  @override
  String get uploadFotoGagal => 'Photo upload failed';

  @override
  String get uploadFotoGagalUrl => 'Photo upload failed: no URL returned';

  @override
  String get jenisKerusakanDeskripsi =>
      'Type of damage (road, drainage, bridge, etc)';

  @override
  String get penjelasanDariPelapor => 'Detailed explanation from reporter';

  @override
  String rentangTanggalLabel(String range) {
    return 'Date Range: $range';
  }

  @override
  String auditLogExportSubjek(String format) {
    return 'Audit Log Export ($format)';
  }

  @override
  String get penggunaSigap => 'SIGAP User';

  @override
  String get aktifkanLokasiUntukMelihatPeta =>
      'Enable location to view your map';

  @override
  String get dariTanggal => 'From Date';

  @override
  String get sampaiTanggal => 'Until Date';

  @override
  String get tugasAkanMunculDiSini => 'Tasks will appear here';

  @override
  String get laporanAndaKirimkanMuncul => 'Reports you submit will appear here';

  @override
  String countMenunggu(int count) {
    return '$count waiting';
  }

  @override
  String tugasTersimpanOfflineCount(int count) {
    return '$count tasks saved offline';
  }

  @override
  String get labelLaporanChart => 'reports';

  @override
  String get labelKasusChart => 'cases';

  @override
  String get tidakAdaDataTren => 'No trend data';

  @override
  String petugasPerluDitugaskan(int count) {
    return '$count officers need assignment';
  }

  @override
  String kasusBerisikoTerlambat(int count) {
    return '$count cases at risk of delay';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get tugasSurveiTitle => 'Survey Tasks';

  @override
  String get tugasPetugasTitle => 'Officer Tasks';

  @override
  String get tugasSurveiDeskripsi =>
      'All field survey tasks assigned to you will appear here.';

  @override
  String get tugasPetugasDeskripsi =>
      'You have no tasks in this list. Refresh after an admin assigns work to you.';

  @override
  String terlambatXjam(int hours) {
    return '$hours hours overdue';
  }

  @override
  String slaXjam(int hours) {
    return 'Due in $hours hours';
  }

  @override
  String get slaBesok => 'Due tomorrow';

  @override
  String slaXhari(int days) {
    return 'Due in $days days';
  }

  @override
  String get adminMemintaInfo =>
      'The admin requested additional information to complete this report.';

  @override
  String tenggatTanggal(String date) {
    return 'Deadline $date.';
  }

  @override
  String get eventFallback => 'Report update';

  @override
  String get simpanSinkronkanNanti => 'Save and sync later';

  @override
  String get kondisiBerat => 'Heavy';

  @override
  String get dampakKeselamatanAkses => 'Safety · access disrupted';

  @override
  String get exportInfoDeskripsi =>
      'Export reports in CSV, GeoJSON, or PDF format. Data will be filtered according to selected options.';

  @override
  String get exportCsvDeskripsi =>
      'Export report data in CSV format for Excel or Google Sheets.';

  @override
  String get exportGeojsonDeskripsi =>
      'Export report data with geospatial coordinates for GIS.';

  @override
  String get exportPdfDeskripsi => 'Export complete report in PDF format.';

  @override
  String get exportCsvGagal => 'CSV export failed:';

  @override
  String get exportGeojsonGagal => 'GeoJSON export failed:';

  @override
  String get exportPdfGagal => 'PDF export failed:';

  @override
  String get faktorKeparahan => 'Severity Level (Severity)';

  @override
  String get faktorKebaruan => 'Report Recency (Recency)';

  @override
  String get faktorUrgensi => 'Category Urgency (Category)';

  @override
  String get faktorKepadatan => 'Region Density (Location)';

  @override
  String get faktorRiwayat => 'Region/Report History (History)';

  @override
  String get totalBobotSesuai => 'Total weight: 100% (Correct)';

  @override
  String totalBobotDisarankan(int total) {
    return 'Total weight: $total% (Recommended 100%)';
  }

  @override
  String get roleDescAdmin =>
      'Manage regional master data, UPT units, SLA, and priority weight configuration.';

  @override
  String get roleDescPetugas =>
      'Technical field follow-up and complaint resolution.';

  @override
  String get roleDescWarga =>
      'Submit public complaint reports and monitor completion status.';

  @override
  String get roleDescDefault => 'Access SIGAP system operational features.';

  @override
  String get assessmentAiMunculNanti =>
      'AI Assessment will appear after the report is submitted and processed.';

  @override
  String reportLabelId(String id) {
    return 'Report: $id';
  }

  @override
  String laporanCountLabel(int count) {
    return '$count reports';
  }

  @override
  String semuaLabel(String label) {
    return 'All $label';
  }

  @override
  String targetJamHari(int hours, double days) {
    return 'Target: $hours hours ($days days)';
  }

  @override
  String slaOverdueLaporan(int count) {
    return '$count reports';
  }

  @override
  String get syncChannelName => 'Sync Notifications';

  @override
  String get syncChannelDescription => 'Notifications for sync events';

  @override
  String itemTidakDisinkronkanPercobaan(String key) {
    return 'Item $key could not be synced after several attempts.';
  }

  @override
  String get beberapaItemTidakDisinkronkan =>
      'Some items could not be synced after several attempts.';

  @override
  String get pilihWilayahFallback => 'Select Region';

  @override
  String get kabBandungFallback => 'Kab. Bandung';

  @override
  String get draftLabelStatus => 'Draft';

  @override
  String get digabungLabelStatus => 'Merged';

  @override
  String get dipisahLabelStatus => 'Split';

  @override
  String get dalamReviewLabelStatus => 'Under review';

  @override
  String get noAssessmentFactors => 'No assessment factors available.';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String diperbaruiPada(Object time) {
    return 'Updated: $time';
  }

  @override
  String get akurasiSedang => 'Moderate accuracy';

  @override
  String get akurasiBuruk => 'Poor accuracy';

  @override
  String get laporanPendukungCount => 'supporting reports';

  @override
  String get statusOnline => 'Connected';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusSyncing => 'Syncing';

  @override
  String get statusErrorLabel => 'Error';

  @override
  String sinkronStatusA11y(Object status) {
    return 'Sync status: $status';
  }

  @override
  String get bukaPusatSinkronisasiLink => 'Open Sync Center →';

  @override
  String laporanBelumTersinkronCount(Object count) {
    return '$count reports not yet synced';
  }

  @override
  String get defaultPrivatPetugas =>
      'Limit account identity to authorized staff';

  @override
  String severityColonValue(Object value) {
    return 'Severity: $value';
  }

  @override
  String scoreColonValue(Object value) {
    return 'Score: $value';
  }

  @override
  String get ringkasanLaporanUppercase => 'REPORT SUMMARY';

  @override
  String get waktuLabel => 'Time';

  @override
  String get dampakLabel => 'Impact';

  @override
  String fotoIndexPlaceholder(Object index) {
    return 'photo $index';
  }

  @override
  String get checklistWajib => 'REQUIRED CHECKS';

  @override
  String kasusSerupaDitemukan(Object count) {
    return '$count similar cases found nearby';
  }

  @override
  String get kemiripanLabel => 'similarity';

  @override
  String get naLabel => 'N/A';

  @override
  String get lessThan1dLabel => '<1d';

  @override
  String get sayaMenyatakanBenar =>
      'I declare this information is true according to the conditions I observed.';

  @override
  String get terimaTugasLabel => 'Accept Task';

  @override
  String get labelSubmitted => 'Submitted';

  @override
  String get labelUnderReview => 'Under Review';

  @override
  String get labelDiproses => 'In Progress';

  @override
  String get labelTerverifikasi => 'Verified';

  @override
  String get labelSelesai => 'Resolved';

  @override
  String get labelDitolak => 'Rejected';

  @override
  String get labelBaru => 'New';

  @override
  String get labelDitugaskan => 'Assigned';

  @override
  String get labelDikerjakan => 'In Progress';

  @override
  String get reportPhotoPreparationFailed =>
      'SIGAP could not prepare this photo. Choose JPG, PNG, or WebP with an original size of at most 10 MB.';

  @override
  String get taskAcceptStart => 'Accept and start survey';

  @override
  String get taskAwaitingReview =>
      'A field worker has submitted the work results. Wait for admin review; submission does not yet close the resident report.';

  @override
  String get taskChecklistMissing =>
      'The admin has not configured the checks for this category. Ask the admin to add them before you submit survey results.';

  @override
  String get taskCitizenEvidence => 'Citizen photos';

  @override
  String get taskContinueSurvey => 'Continue survey';

  @override
  String get taskDepth => 'Depth';

  @override
  String get taskDetailsTitle => 'Task details';

  @override
  String get taskFindings => 'Observed conditions';

  @override
  String get taskHeight => 'Height';

  @override
  String get taskInstructions => 'Read the field instructions';

  @override
  String get taskInstructionsMissing =>
      'This task has no field instructions yet. Ask for clarification before deciding what work to carry out.';

  @override
  String get taskLength => 'Length';

  @override
  String get taskMeasurements => 'Recorded measurements';

  @override
  String get taskNotes => 'Worker notes';

  @override
  String get taskPhotosLoadFailed =>
      'SIGAP could not open the reporter’s photos. Check your connection, then reload them.';

  @override
  String get taskRecommendation => 'Recommended next steps';

  @override
  String get taskRequiredChecklist => 'Required checks';

  @override
  String get taskResolved =>
      'The admin has approved the work results and completed this report.';

  @override
  String get taskSavedPhotosOnline =>
      'SIGAP stores this task on this device. Connect to the internet to open photos that have not loaded.';

  @override
  String get taskSavePreparation =>
      'Save this task before you travel so you can read the instructions without internet.';

  @override
  String get taskSurveyPhotos => 'Survey photos';

  @override
  String get taskSurveyResults => 'Review the survey findings';

  @override
  String get taskWidth => 'Width';

  @override
  String taskPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get mobileNotSaved => 'Not saved';

  @override
  String get mobileSaveThisTaskToPrepareForTheSurvey =>
      'Save this task before you travel to the site.';

  @override
  String get mobileAcceptStartSurvey => 'Accept and start survey';

  @override
  String get mobileNoInternetAccess => 'The device is not connected';

  @override
  String get mobileInternetConnected =>
      'The device is connected to the internet';

  @override
  String get mobileCheckingConnection => 'Checking connection';

  @override
  String get mobileConnectTheDeviceToTheInternetBeforeSyncing =>
      'Connect the device to the internet before syncing.';

  @override
  String get mobileQueuedItemsRemainSavedUntilInternetAccessReturns =>
      'SIGAP keeps this queue on your device. Connect to the internet, then send it and check the result here.';

  @override
  String get mobileTaskLocationsForAuthorizedFieldWorkers =>
      'Use task locations to prepare your visit. Compare each point with the address and field instructions before travelling.';

  @override
  String get mobileTapAMarkerToSeeTheTaskSummary =>
      'Tap a marker to see the task summary.';

  @override
  String get mobileTaskLocations => 'Task locations';

  @override
  String get mobileOfficeAddressOptional => 'Office address (optional)';

  @override
  String get mobileContactPhoneOptional => 'Contact / Phone (optional)';

  @override
  String get mobileEditWorkUnit => 'Edit work unit';

  @override
  String get mobileChooseTheUnitThatWillHandleThisCase =>
      'Choose the unit that will handle this case.';

  @override
  String get mobileNoActiveUnits => 'No active units.';

  @override
  String get mobileDepartmentsUnits => 'Departments & units';

  @override
  String get mobileArea => 'Area';

  @override
  String get mobileChangeCaseStatus => 'Change case status';

  @override
  String get mobilePrimaryReportUUID => 'Primary report UUID';

  @override
  String get mobileReceivingUnitUUID => 'Receiving unit UUID';

  @override
  String get mobileReceivingUnitOptional => 'Receiving unit (optional)';

  @override
  String get mobileReportsMergedSuccessfully => 'Reports merged successfully';

  @override
  String get mobileNoDuplicatesFound => 'No duplicates found';

  @override
  String get mobileCompareDuplicateCandidates => 'Compare duplicate candidates';

  @override
  String get mobilePhotoUnavailable => 'Photo unavailable';

  @override
  String get mobileLocationUnavailable => 'Location unavailable';

  @override
  String get mobileAssignSurveyTask => 'Assign survey task';

  @override
  String get mobileOpenCaseDetails => 'Open case details ↗';

  @override
  String get mobileEnableLocationToViewTheMap =>
      'Enable location to view the map';

  @override
  String get mobileCaseStatus => 'Case status';

  @override
  String get mobileVerifiedCompleted => 'Verified / completed';

  @override
  String get mobileAwaitingFollowUp => 'Awaiting follow-up';

  @override
  String get mobileInProgress => 'In progress';

  @override
  String get mobileLocationsAreGeneralizedToProtectReporterPrivacyPDPLaw =>
      'The public map shows approximate locations to limit sharing of reporters’ precise coordinates.';

  @override
  String get mobileAppearanceLanguage => 'Appearance & language';

  @override
  String get mobileTheme => 'Theme';

  @override
  String get mobileSystemDefault => 'System default';

  @override
  String get mobileDark => 'Dark';

  @override
  String get mobileLight => 'Light';

  @override
  String get mobileLanguage => 'Language';

  @override
  String get mobileActiveAreaDeviceLocation => 'Active area · device location';

  @override
  String get mobileABetterVillageStartsWithOurCare =>
      'Help improve your village\nby reporting conditions around you.';

  @override
  String get mobilePhotoLocationAndFieldConditions =>
      'Photo, location and field conditions';

  @override
  String get mobileSafeOnThisDeviceSendWhenConnected =>
      'SIGAP keeps pending submissions on this device. Check their delivery when internet is available.';

  @override
  String get mobileAllReportsSynced =>
      'No reports are waiting to send from this device.';

  @override
  String get mobileSyncStatusIsUnavailable => 'Sync status is unavailable.';

  @override
  String get mobileMyReports => 'My reports';

  @override
  String get mobileViewAll => 'View all →';

  @override
  String get mobileReloadReportSummary => 'Reload report summary';

  @override
  String get mobileCasesNearYou => 'Cases near you';

  @override
  String get mobileOpenMap => 'Open map ↗';

  @override
  String get mobileAllowDeviceLocationToSeeNearbyCases =>
      'Allow device location to see nearby cases.';

  @override
  String get mobileNoNearbyCasesYet =>
      'SIGAP found no reports within this area. Move the map or reload to view other locations.';

  @override
  String get mobileReloadNearbyCases => 'Reload nearby cases';

  @override
  String get mobileYourIdentityIsSafePublicReportsDoNotShow =>
      'The public portal does not show the reporter’s account identity. Avoid including personal details in descriptions or photos.';

  @override
  String get mobileFacilityReport => 'Facility report';

  @override
  String get mobileQueued => 'Not sent';

  @override
  String get mobileNoReportsInThisCategoryYet =>
      'No reports match this selection. Change the filter or create a report if you find a new issue.';

  @override
  String get mobileCreateNewReport => '+ Create new report';

  @override
  String get mobileViewProgress => 'View progress →';

  @override
  String get mobileAccountDevice => 'Account & device';

  @override
  String get mobileUserContext => 'Your signed-in account';

  @override
  String get mobileResident => 'Resident';

  @override
  String get mobileSurveyor => 'Field worker';

  @override
  String get mobileAdministrator => 'Administrator';

  @override
  String get mobileUser => 'User';

  @override
  String get mobileAuthenticatedAccount => 'You are signed in';

  @override
  String get mobileConnectionStatus => 'Check the device connection';

  @override
  String get mobileSaveReportsOnThisDeviceWhileDisconnected =>
      'You can save reports without internet. Check the sync center after the connection returns.';

  @override
  String get mobileSignOut => 'Sign out';

  @override
  String get mobileSyncCenter => 'Sync center';

  @override
  String get mobileAnInternetConnectionIsRequiredToSendAdditionalEvidence =>
      'An internet connection is required to send additional evidence.';

  @override
  String get mobileYouAreOffline => 'Connect this device to the internet';

  @override
  String get mobileReadyToSyncData => 'Send the queue when you are ready';

  @override
  String get mobileSendReportsAndSurveyResultsToTheOperatorWorkspace =>
      'Send the queue so staff can read your reports and surveys. Check the delivery results before leaving this page.';

  @override
  String get mobileNoPendingSubmissionsAllDataOnThisDeviceIs =>
      'This device has no queued submissions. Drafts you have not submitted are not part of this queue.';

  @override
  String get mobileSurveyResult => 'Survey result';

  @override
  String get mobileResidentReport => 'Resident report';

  @override
  String get mobilePending => 'Pending';

  @override
  String get mobileRetry => 'Retry';

  @override
  String get mobileSyncing => 'Syncing…';

  @override
  String get mobileTheQueueIsStoredOnThisDevice =>
      'This list shows only the queue on this device. Open report details to check submissions that have arrived.';

  @override
  String get mobileSomeSubmissionsAreStillPendingYourDataRemainsSafe =>
      'SIGAP has not sent every queued item. Review the items you need to retry; do not delete data before confirming delivery.';

  @override
  String get mobileReportDetails => 'Report details';

  @override
  String get mobileYourReportHelpsStaffUnderstandFacilityConditions =>
      'Your report helps staff understand facility conditions.';

  @override
  String get mobileRELATEDCASE => 'RELATED CASE';

  @override
  String get mobileViewRelatedCase => 'View related case →';

  @override
  String get mobileReportProgress => 'Report progress';

  @override
  String get mobileNoReportUpdatesYet =>
      'This report has no recorded updates yet. Reload later to check for progress.';

  @override
  String get mobileReloadProgress => 'Reload progress';

  @override
  String get mobileOnlyAuthorizedStaffCanAccessReporterDetails =>
      'Authorized staff can access reporter details to follow up. The public portal does not show your account identity.';

  @override
  String get mobileReloadReport => 'Reload report';

  @override
  String get mobileAwaitingSync => 'Awaiting sync';

  @override
  String get mobileYourReportIsSafeOnThisDeviceOpenSync =>
      'SIGAP has saved this report only on this device; staff have not received it. Open the sync center when internet is available.';

  @override
  String get mobileAwaitingReportSubmission => 'Awaiting report submission';

  @override
  String get mobileNoCaseIDAssignedYet =>
      'Send the report first so SIGAP can assign a report number.';

  @override
  String get mobileSavedOnDevice => 'Saved on device';

  @override
  String get mobileWaitingForAConnectionToSendTheReport =>
      'Connect to the internet and open the sync center to send this report.';

  @override
  String get mobileAdditionalEvidenceSent =>
      'You have added evidence to this report.';

  @override
  String get mobileStaffRequestedAnotherPhoto =>
      'Add the evidence requested by staff';

  @override
  String get mobileNewPhoto => 'New photo';

  @override
  String get mobileChoosePhotoFromDevice => 'Choose photo from device';

  @override
  String get mobileSending => 'Sending…';

  @override
  String get mobileSendAdditionalEvidence => 'Send additional evidence';

  @override
  String get mobileReportSuccessfullySentToStaff =>
      'SIGAP has received your report. Open report details to follow its review and progress.';

  @override
  String get mobilePhotoEvidence => 'Photo evidence';

  @override
  String get mobileCondition => 'Condition';

  @override
  String get mobileReview => 'Review';

  @override
  String get mobileBack => '← Back';

  @override
  String get mobileSendReport => 'Send report';

  @override
  String get mobileContinue => 'Continue →';

  @override
  String get mobileWhatWouldYouLikeToReport => 'What would you like to report?';

  @override
  String get mobileChooseTheTypeOfDamagedFacility =>
      'Choose the type of damaged facility.';

  @override
  String get mobileReportTitle => 'Report title';

  @override
  String get mobileExamplePotholeNearTheMarket =>
      'Example: Pothole near the market';

  @override
  String get mobileShowTheConditionsOnSite => 'Show the conditions on site';

  @override
  String get mobileTakeAClearPhotoWithoutFacesOrPersonalDetails =>
      'Show the facility and damage clearly. Avoid unnecessary faces, vehicle plates, or personal documents.';

  @override
  String get mobileUPLOADEDEVIDENCE => 'UPLOADED EVIDENCE';

  @override
  String get mobileNoPhotoYet => 'You have not selected a photo';

  @override
  String get mobileTakeOrChooseAPhotoFromYourDevice =>
      'Take or choose a photo from your device';

  @override
  String get mobilePNGJPGWebPMax1MB =>
      'Choose JPG, PNG, or WebP. SIGAP prepares a copy up to 1 MB; the original must not exceed 10 MB.';

  @override
  String get mobileReplacePhoto => 'Replace photo';

  @override
  String get mobileRemovePhoto => 'Remove photo';

  @override
  String get mobileWhereIsItLocated => 'Where is it located?';

  @override
  String get mobileChooseAVillageAndTheFacilityLocationOnThe =>
      'Choose a village and the facility location on the map.';

  @override
  String get mobileVillage => 'Village';

  @override
  String get mobileTapTheMapToMoveThePinPublicCoordinates =>
      'Tap the map to move the point. The public portal shows an approximate location rather than the report’s precise coordinates.';

  @override
  String get mobileDescribeTheConditionsYouSee =>
      'Describe the conditions you see';

  @override
  String get mobileDetailsHelpStaffPrioritizeRepairs =>
      'Explain the damaged area and its impact. Staff use this description with the photo to decide the next review step.';

  @override
  String get mobileDamageLevel => 'Damage level';

  @override
  String get mobileDescriptionImpact => 'Description & impact';

  @override
  String get mobileDescribeTheDamageSizeRisksAndAffectedResidents =>
      'Describe the damage size, risks and affected residents…';

  @override
  String get mobileDescribeWhatYouObservedDoNotIncludeNamesPhone =>
      'Describe what you observed. Do not include names, phone numbers or personal data.';

  @override
  String get mobileASimilarCaseWasFoundNearThisLocation =>
      'Review nearby reports before adding evidence. Nearby locations do not prove that reports describe the same issue.';

  @override
  String get mobileAddEvidence => 'Add evidence';

  @override
  String get mobileCreateSeparately => 'Create separately';

  @override
  String get mobileMinor => 'Minor';

  @override
  String get mobileSevere => 'Severe';

  @override
  String get mobileCoordinates => 'Coordinates';

  @override
  String get mobileSurveyHistory => 'Survey history';

  @override
  String get mobileTodaySTasks => 'Today’s tasks';

  @override
  String get mobileRunAIAnalysis => 'Run AI analysis';

  @override
  String get mobileAnalysisInProgress => 'Analysis in progress…';

  @override
  String get mobileAnalysisCompleted => 'Analysis completed';

  @override
  String get mobileAIPreVerificationConsolidationQueue =>
      'AI Pre-verification & Consolidation Queue';

  @override
  String get mobileMetadataChecksPhotoValidationAndGroupingOfNearbyReports =>
      'Metadata checks, photo validation and grouping of nearby reports within 50–100 meters.';

  @override
  String get mobileRunAIAnalysisUsingTheButtonTheVerifierMakes =>
      '✧ Run AI analysis using the button. The verifier makes the final decision.';

  @override
  String get mobileHumanVerificationRequired => 'Human verification required';

  @override
  String get mobilePossibleDuplicate => 'Possible duplicate';

  @override
  String get mobileLowMediaQuality => 'Low media quality';

  @override
  String get mobileAICompleted => 'AI completed';

  @override
  String get mobileEvidence => 'Evidence';

  @override
  String get mobileIdentityConcealed => 'identity concealed';

  @override
  String get mobileNotAnalyzed => 'Not analyzed';

  @override
  String get mobileUnableToAssess => 'Unable to assess';

  @override
  String get mobileIdentifiedDamage => 'Identified damage';

  @override
  String get mobileReportsPointToTheSameObject =>
      'reports point to the same object';

  @override
  String get mobileApproveAsNewCase => 'Approve as new case';

  @override
  String get mobileMergeIntoExistingCase => 'Merge into existing case';

  @override
  String get mobileAssignFieldSurvey => 'Assign field survey';

  @override
  String get mobileRequestMorePhotos => 'Request more photos';

  @override
  String get mobileRejectReport => 'Reject report';

  @override
  String get mobileDetails => 'Details ↗';

  @override
  String get mobileDecisionReason => 'Decision reason';

  @override
  String get mobileNoReportsInThisQueue => 'No reports in this queue.';

  @override
  String get mobileMoreInformationNeeded => 'More information needed';

  @override
  String get mobileQuickSurveyNeeded => 'Quick survey needed';

  @override
  String get mobileAwaitingVerification => 'Awaiting verification';

  @override
  String get mobileWhatNeedsAttentionToday => 'What needs attention today?';

  @override
  String get mobileCurrentInfrastructureConditionsAndFollowUpActions =>
      'Current infrastructure conditions and follow-up actions.';

  @override
  String get mobileOverdueSLA => 'Overdue SLA';

  @override
  String get mobileNeedsInformation => 'Needs information';

  @override
  String get mobileViewRelatedCases => 'View related cases ↗';

  @override
  String get mobileReportsReceivedAndCompletedLast30Days =>
      'Reports received and completed · last 30 days';

  @override
  String get mobileCasesInYourArea => 'Cases in your area';

  @override
  String get mobileOpenFullMapCases => 'Open full map & cases ↗';

  @override
  String get mobileCasesRequiringAttention => 'Cases requiring attention';

  @override
  String get mobileNoCriticalCasesInThisArea =>
      'No critical cases in this area.';

  @override
  String get mobileDataQualitySynchronization =>
      'Data quality & synchronization';

  @override
  String get mobileReportsReceivedByServer => 'Reports received by server';

  @override
  String get mobileOfflineDeviceQueuesAreAvailableInTheSyncCenter =>
      'Offline device queues are available in the sync center.';

  @override
  String get mobileCitizenDataIsProtectedEveryOperatorDecisionIsRecorded =>
      'Citizen data is protected. Every operator decision is recorded in the audit history.';

  @override
  String get mobileReportsReceived => 'Reports received';

  @override
  String get mobileCasesCompleted => 'Cases completed';

  @override
  String get mobileNoTrendDataYet => 'No trend data yet';

  @override
  String get mobileWORKSPACE => 'WORKSPACE';

  @override
  String get mobileGOVERNANCE => 'GOVERNANCE';

  @override
  String get mobileOverview => 'Overview';

  @override
  String get mobileMapCases => 'Map & cases';

  @override
  String get mobileAIPreVerification => 'AI pre-verification';

  @override
  String get mobileTasksProgress => 'Tasks & progress';

  @override
  String get mobileAnalyticsHeatmap => 'Analytics & heatmap';

  @override
  String get mobileExportReports => 'Export reports';

  @override
  String get mobileAdministration => 'Administration';

  @override
  String get mobileAllAreas => 'All areas';

  @override
  String get mobileSearchCasesVillagesOrIDs =>
      '⌕  Search cases, villages or IDs…';

  @override
  String get mobileCitizenDataIsProtectedDecisionsAreRecordedInThe =>
      'Citizen data is protected. Decisions are recorded in the audit log.';

  @override
  String get mobileCurrentReport => 'Current report';

  @override
  String get mobileDuplicateCandidate => 'Duplicate candidate';

  @override
  String get mobileSimilarity => 'Similarity';

  @override
  String get mobileNearbyReports => 'Nearby reports';

  @override
  String get mobileChangeStatus => 'Change status';

  @override
  String get mobileExportCase => 'Export case';

  @override
  String get mobileAssignUnit => 'Assign unit';

  @override
  String get mobileVerifyPrioritize => 'Verify & prioritize';

  @override
  String get mobileDamageDimensions => 'Record damage measurements';

  @override
  String get mobileExampleLength2MWidth1M =>
      'Include each measurement and its unit. If you have not measured the damage, explain why.';

  @override
  String get mobileTapAPhotoToReplaceItMaximum1MB =>
      'Take photos from different angles so the admin can compare conditions. Tap a photo to replace it; each photo must be at most 1 MB.';

  @override
  String get mobileAlreadyRepaired =>
      'I observed that the issue has been addressed';

  @override
  String get mobileResultsGoToTheOperatorForVerificationOfflineResults =>
      'Send your results so the admin can review your findings. If you are offline, save them to the queue and send them when internet is available.';

  @override
  String get mobileSaveDraft => 'Save draft';

  @override
  String get mobileNewDraft => 'New draft';

  @override
  String get mobileDraftSaved => 'Draft saved';

  @override
  String get mobileFIELDINSTRUCTIONS => 'FIELD INSTRUCTIONS';

  @override
  String get mobileREQUIREDCHECKLIST => 'REQUIRED CHECKS';

  @override
  String get mobileCitizenEvidence => 'Citizen evidence';

  @override
  String get mobileNoCitizenPhotosYet =>
      'This report has no resident photos. Ask for more evidence if you need it to prepare for the survey.';

  @override
  String get mobileSurveyResultsSubmitted => 'Survey results submitted';

  @override
  String get mobileRequestClarification => 'Ask for clarification';

  @override
  String get mobileDeclineTask => 'Decline task';

  @override
  String get mobileSaveTask => '↓ Save task';

  @override
  String get mobileSaveAll => '↓ Save all';

  @override
  String get mobileAvailableLocally => '✓ Task saved on this device';

  @override
  String get mobileDue => 'Deadline';

  @override
  String get mobileNotSet => 'Not set';

  @override
  String get mobileLocationNotSet => 'Location not set';

  @override
  String get mobileNoSurveyResultsYetSubmittedResultsWillAppearHere =>
      'You have not submitted survey results yet. After you send them, return here to review your notes and evidence.';

  @override
  String get mobileMyPublicIdentity => 'Review report privacy';

  @override
  String get mobilePrivateVisibleOnlyToStaff =>
      'SIGAP limits account identity to authorized staff.';

  @override
  String get mobileIConfirmThisInformationAccuratelyDescribesWhatIObserved =>
      'I confirm this information accurately describes what I observed.';

  @override
  String get mobileNearbyMap => 'Nearby map';

  @override
  String get mobilePublicCasesGeneralizedLocations =>
      'View reports at approximate public locations';

  @override
  String get mobileReloadMap => 'Reload map';

  @override
  String get mobileTapAPinToSeeFacilityDetailsPublicCoordinates =>
      'Tap a point to read the report. This map uses approximate public locations; do not treat them as exact survey directions.';

  @override
  String get mobileCasePriorityScore => 'Case priority score';

  @override
  String get mobilePeopleAffected => 'People affected';

  @override
  String get mobileSupportingReports => 'Supporting reports';

  @override
  String get mobileSLAOverdue => 'Past the deadline';

  @override
  String get mobileScoreNotAvailable => 'Score not available';

  @override
  String get mobileISSUEIMPACT => 'ISSUE IMPACT';

  @override
  String get mobileResidentsAffected => 'Residents affected';

  @override
  String get mobileTimelineAndDecisions => 'Timeline and decisions';

  @override
  String get mobileResidentPrivacyReporterIdentitiesAreExcludedFromThePublic =>
      'Resident privacy\nReporter identities are excluded from the public portal.';

  @override
  String get mobileNoAIResultsYetRunTheAssessmentToSee =>
      'No AI results yet. Run the assessment to see results.';

  @override
  String get mobileAIAssessmentResults => 'AI assessment results';

  @override
  String get mobileConsolidatedSupportingReports =>
      'consolidated supporting reports';

  @override
  String get mobileCaseActions => 'Case actions:';

  @override
  String get connectionOnline => 'Connected';

  @override
  String get connectionOffline => 'Offline';

  @override
  String get statusAwaitingClarification => 'Awaiting clarification';

  @override
  String greetingPerson(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String villageWithName(String name) {
    return '$name village';
  }

  @override
  String conditionWithLabel(String condition) {
    return 'Condition: $condition';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String submittedResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results submitted',
      one: '1 result submitted',
    );
    return '$_temp0';
  }

  @override
  String pendingSyncCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count submissions awaiting sync',
      one: '1 submission awaiting sync',
    );
    return '$_temp0';
  }

  @override
  String waitingSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count submissions pending',
      one: '1 submission pending',
    );
    return '$_temp0';
  }

  @override
  String successfulSyncCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count submissions synced successfully.',
      one: '1 submission synced successfully.',
    );
    return '$_temp0';
  }

  @override
  String supportingReportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supporting reports',
      one: '1 supporting report',
    );
    return '$_temp0';
  }

  @override
  String protectedReportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports · identity protected',
      one: '1 report · identity protected',
    );
    return '$_temp0';
  }

  @override
  String photoProgress(int count, int total) {
    return '$count of $total photos';
  }

  @override
  String taskSavedSummary(int count, int saved) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0 · $saved saved locally';
  }

  @override
  String reportStepProgress(int current, int total, String label) {
    return 'Step $current of $total · $label';
  }

  @override
  String distanceWithValue(String distance) {
    return 'Distance: $distance';
  }

  @override
  String saveTaskFailed(String error) {
    return 'Failed to save task: $error';
  }

  @override
  String mergeReportFailed(String error) {
    return 'Merge failed: $error';
  }

  @override
  String slaTargetDuration(int hours, String days) {
    return 'Target: $hours hours ($days days)';
  }

  @override
  String get categoryRoad => 'Road';

  @override
  String get categoryBridge => 'Bridge';

  @override
  String get categoryCleanWater => 'Clean water';

  @override
  String get categoryPublicFacility => 'Public facilities';

  @override
  String get categoryIrrigation => 'Irrigation';

  @override
  String submissionFailedWithReason(String error) {
    return 'Submission failed: $error';
  }

  @override
  String get reportPhotoUploadRetry =>
      'SIGAP could not upload the photo. Your draft and photo remain available; check your connection and send again.';

  @override
  String get minimumEightCharacters => 'At least 8 characters';

  @override
  String get originalPhotoTooLarge => 'Original photo exceeds 10 MB';

  @override
  String get surveyPhotoTooLarge =>
      'Maximum 1 MB per photo. Choose a smaller photo.';

  @override
  String get reportAddressLabel => 'Location address';

  @override
  String get reportVillageLabel => 'Village or neighbourhood';

  @override
  String get reportAddressLookupLoading =>
      'SIGAP is finding an address for this point…';

  @override
  String get reportAddressLookupFailed =>
      'SIGAP could not find an address for this point. Type an address or landmark so staff can find it.';

  @override
  String get reportAddressLookupRetry => 'Find address from pin';

  @override
  String get reportLocationInstruction =>
      'Choose the point where the issue occurred, then check or type its address. Do not use your device location if you are somewhere else.';

  @override
  String get infrastructureLabel => 'Infrastructure';

  @override
  String get infrastructureReportLabel => 'Infrastructure report';

  @override
  String get supportingReportsUnknown =>
      'Supporting report count is unavailable';

  @override
  String get fieldSurveyLabel => 'Field survey';

  @override
  String get reportsUnavailable => 'Reports could not be loaded.';

  @override
  String get fieldWorkerLabel => 'Field worker';

  @override
  String get saveSurveyToQueue => 'Save to queue';

  @override
  String get submitSurveyResult => 'Submit survey result';

  @override
  String get timelineReportCreated => 'The reporter submitted a report';

  @override
  String get timelineAnonymousReportCreated =>
      'The reporter submitted without an account identity';

  @override
  String get reportStatusDraftExplanation =>
      'SIGAP stores this report on your device. Send it so staff can review it.';

  @override
  String get reportStatusSubmittedExplanation =>
      'The report has arrived. Follow the updates below; this stage does not confirm its accuracy or that the issue is resolved.';

  @override
  String get reportStatusReviewExplanation =>
      'Staff are reviewing the report and evidence. Follow the updates for a decision or a request for more information.';

  @override
  String get reportStatusVerifiedExplanation =>
      'Staff have verified the report. Follow assignment and work updates; verification does not mean the work is complete.';

  @override
  String get reportStatusProgressExplanation =>
      'The report is in the handling stage. Follow work updates to see the results submitted by staff.';

  @override
  String get reportStatusResolvedExplanation =>
      'Handling of this report is complete. Read the updates below to see the recorded outcome.';

  @override
  String get reportStatusRejectedExplanation =>
      'Staff rejected this report. Read the reason and appeal if you have information that needs another review.';

  @override
  String get reportStatusNeedsInfoExplanation =>
      'Staff requested more information. Read the request and add evidence that clarifies the reported condition.';

  @override
  String get reportStatusSurveyExplanation =>
      'The report needs a site inspection. Follow assignment and visit updates before drawing conclusions about the outcome.';

  @override
  String get reportStatusLinkedExplanation =>
      'This report is linked to another report. Open the main report to follow how the issue is handled.';

  @override
  String get reportStatusUnknownExplanation =>
      'SIGAP has not received a displayable handling stage. Reload to check for updates.';

  @override
  String get reportStatusOutOfScopeExplanation =>
      'This issue is outside the reporting service’s scope. Read the decision notes for any available guidance.';

  @override
  String get reportLocationMissingExplanation =>
      'This report does not contain an address. Use any recorded location details and ask for directions if you cannot identify the site.';

  @override
  String get reportRelatedExplanation =>
      'SIGAP links this report to a main report. Follow its handling through the link below; supporting reports do not count completed work.';

  @override
  String get reportStandaloneExplanation =>
      'This report is not linked to another main report. Follow its handling on this page.';

  @override
  String get reportPhotoMissingExplanation =>
      'This report has no photo. Add evidence if staff request it.';

  @override
  String get reportPhotoLoadExplanation =>
      'SIGAP could not open the photo. Check your connection and reload the report.';

  @override
  String get mobileTechnicalDetails => 'View technical details';

  @override
  String get mobileRequestFailedExplanation =>
      'SIGAP could not complete this request. Check your connection and try again. If it keeps failing, include the technical details when contacting support.';

  @override
  String get mobileSyncItemFailedExplanation =>
      'SIGAP has not sent this item. Check your connection, choose retry, then send the queue again.';

  @override
  String get mobileSyncLoadFailedExplanation =>
      'SIGAP could not read this device’s queue. Reload before concluding that every item has been sent.';

  @override
  String get mobileNotificationTitle => 'Manage device notifications';

  @override
  String get mobileNotificationEnabled =>
      'SIGAP can show report and task updates in the background. Delivery still requires a device connection.';

  @override
  String get mobileNotificationDenied =>
      'Open Android settings to allow notifications, then enable them here.';

  @override
  String get mobileNotificationFailed =>
      'SIGAP could not register this device for notifications. Check your connection and try again.';

  @override
  String get mobileNotificationUnavailable =>
      'This device cannot receive SIGAP notifications. Open the notification inbox to check updates.';

  @override
  String get mobileNotificationPrompt =>
      'Enable notifications to follow report and task updates on this device.';

  @override
  String get mobileNotificationEnabling => 'SIGAP is enabling notifications…';

  @override
  String get mobileNotificationEnable => 'Enable notifications';

  @override
  String get mobileNotificationDisable => 'Disable notifications';

  @override
  String get mobileAndroidSettings => 'Open Android settings';

  @override
  String get taskLocationExplanation =>
      'Compare the address and report location before travelling. If either is unclear, ask the task issuer for clarification.';

  @override
  String get taskEvidenceExplanation =>
      'Compare the reporter’s evidence with what you observe. Report photos help you prepare but do not replace a site inspection.';

  @override
  String get taskResultsExplanation =>
      'These notes show results staff have submitted. Submitting results is different from admin approval of task completion.';

  @override
  String get statisticsExplanation =>
      'This summary counts reports available to your account. Report totals are not work totals; open a report to read its handling stage.';

  @override
  String get gpsReadingExplanation =>
      'The device estimated this point when you recorded it. Check its accuracy and capture time; GPS alone does not prove the facility’s condition.';

  @override
  String get privacyReportExplanation =>
      'Protecting account identity does not remove personal details from photos or descriptions. Review the evidence before sending it.';

  @override
  String get reportClosedStatus => 'Closed';

  @override
  String get taskSubmittedStatus => 'SIGAP received the results';

  @override
  String get mobileSummaryUnavailable =>
      'SIGAP has not received all summary figures. Open the report list to check the available data.';

  @override
  String get reportReviewExplanation =>
      'Review the photo, location, time and description before sending. Go back to the previous step if you need to correct anything.';

  @override
  String get reportConditionUnknown => 'You have not recorded the condition';

  @override
  String get reportCaptureTimeUnknown =>
      'The photo has no readable capture time.';

  @override
  String get reportImpactUnknown => 'You have not added an impact description.';

  @override
  String get categoryUnknown => 'Category not recorded';

  @override
  String get similarCaseHint =>
      'Compare the photos and descriptions. Add evidence only if the report describes the same incident.';

  @override
  String get gpsAccuracyMeaning =>
      'This figure estimates positional accuracy, not your distance from the facility.';

  @override
  String statusStepRecorded(String status) {
    return 'SIGAP recorded this stage: $status.';
  }

  @override
  String get mobileRetryRequestExplanation =>
      'SIGAP could not complete this request. Check your connection and try again.';
}
