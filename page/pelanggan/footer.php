
<svg xmlns="http://www.w3.org/2000/svg" style="margin-top: -5px;" viewBox="0 0 1440 320"><path fill="#f5f5f5" fill-opacity="1" d="M0,160L60,144C120,128,240,96,360,106.7C480,117,600,171,720,176C840,181,960,139,1080,128C1200,117,1320,139,1380,149.3L1440,160L1440,0L1380,0C1320,0,1200,0,1080,0C960,0,840,0,720,0C600,0,480,0,360,0C240,0,120,0,60,0L0,0Z"></path></svg>

<footer>
    <div class="left">
        <div class="logo-navbar">
            <div class="logo"><img src="assets/img/logo.png" alt="logo"></div>
            <div><h3>Toko SHOES</h3><p>store</p></div>
        </div>
        <div class="footer-links">
            <a href="index.html">Home</a>
            <a href="index.html#product">Product</a>
            <a href="index.html#about">About</a>
            <a href="index.html#contact">contact</a>
        </div>
        <span class="copy">&copy; </span>
    </div>
    <div class="center">
        <h2>Contact</h2>
        <div>
            <div class="footer-contact">
                <i class="bi bi-envelope-fill"></i>
                <span> T-SHOESutm2@gmail.com</span>
            </div>
            <div class="footer-contact">
                <i class="bi bi-telephone-fill"></i>
                <span> +6285708900012</span>
            </div>
        </div>  
    </div>
    <div class="right">
        <h2>About</h2>
        <p>T-SHOES Store Menyediakan berbagai produk yang sangat berkualitas, dijamin produk terbaik dan anda puas</p>
        <div class="medsos">
            <a href=""><i class="bi bi-facebook"></i></a>
            <a href=""><i class="bi bi-instagram"></i></a>
            <a href=""><i class="bi bi-twitter"></i></a>
            <a href="https://T-SHOESutm.wordpress.com/"><i class="bi bi-globe"></i></a>
        </div>
    </div>
    <span class="copy">&copy; 2022 gblk TEAM.</span>
</footer>
<script src="https://unpkg.com/swiper@8/swiper-bundle.min.js"></script>
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>

<script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
<script src="assets/js/script.js"></script>
<script>
    AOS.init();
</script>
<script>
    $('#centang').change(function() {
    if (this.checked) {
        var namaProduk = $('#nama-produk').val();
        var jumlahStok = $('#jumlah-stok').val();
        console.log('Nama Produk: ' + namaProduk);
        console.log('Jumlah Stok: ' + jumlahStok);
    }
    });
</script>
<script>
$(document).ready(function () {
    $('.item-radio').change(function() {
        var ukuran = $(this).val();
        var id = $(this).data('id');
        // Mengirim permintaan AJAX ke server-side script
        $.ajax({
            url: 'data_stok.php',
            method: 'POST',
            data: { ukuran: ukuran, id : id},
            success: function(response) {
                $('#stok-tersedia').text(response);
            }
        });
    });
});
</script>
<script>
$(document).ready(function () {
    function cekTotalHarga() {
        var hargaTotal = 0;
        $('input[type="checkbox"][name="produk[]"]:checked').each(function() {
            var jumlahProduk = parseInt($(this).closest('tr').find('.jumlah').val());
            var hargaSatuanProduk = $(this).data('harga');
            var subtotal = hargaSatuanProduk * jumlahProduk;
            hargaTotal += subtotal;
        });
        var isChecked = $('input[type="checkbox"][name="produk[]"]:checked').length > 0;
        $('.submit-btn').prop('disabled', !isChecked);
        $('#total-checkout').text('Rp. ' + hargaTotal);
    }

    $('.item-check').change(cekTotalHarga);
    $('.jumlah').change(cekTotalHarga);
});
</script>
<script>
    var hargaPerStok = parseInt($('#harga-per-stok').text());
    var stokInput = $('#stok-input');
    var totalHarga = $('#total-harga');
    var tInpHarga = $('#inp-harga-total');

    function hitungTotalHarga() {
    var currentStok = parseInt(stokInput.val());
    var calculatedHarga = currentStok * hargaPerStok;
    totalHarga.text('Rp. ' + calculatedHarga);
    tInpHarga.val(calculatedHarga);
    }

    $('#tambah-btn').click(function() {
    var currentStok = parseInt(stokInput.val());
    var stokTersedia = $('#stok-tersedia').text();
    if (currentStok < stokTersedia) {
        stokInput.val(currentStok + 1);
        hitungTotalHarga();
    }
    });

    $('#kurang-btn').click(function() {
    var currentStok = parseInt(stokInput.val());
    if (currentStok > 1 ) {
        stokInput.val(currentStok - 1);
        hitungTotalHarga();
    }
    });

    stokInput.on('input', function() {
    hitungTotalHarga();
    });
  </script>
  <script>
    $(document).ready(function() {
      var $dropdownToggle = $('.dropdown-toggle');
      var $dropdownMenu = $('.dropdown-menu');

      $dropdownToggle.on('click', function() {
        $dropdownMenu.toggleClass('show');
      });

      $(document).on('click', function(event) {
        var isClickInsideDropdown = $dropdownToggle.is(event.target) || $dropdownMenu.has(event.target).length > 0;
        if (!isClickInsideDropdown) {
          $dropdownMenu.removeClass('show');
        }
      });
    });
  </script>
  <script>
    $(document).ready(function() {
        $('#bank').change(function() {
            var selectedBank = $(this).children("option:selected");
            var noRek = selectedBank.data('no');
            $('#no_rek').text(noRek);
        });
    });
    </script>
</body>
</html>
