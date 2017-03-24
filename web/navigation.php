<?php
?>
<!DOCTYPE html>
</<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Castlemain Capital</title>
<!--
    <link rel="stylesheet" href="css/bootstrap.css">

    <link rel="stylesheet" href="css/style.css">

    <link rel="stylesheet" href="font-awesome/css/font-awesome.min.css">-->

    <!-- Favicon -->
    <!-- Animate.css -->
    <link rel="stylesheet" href="css/animate.css">
    <!-- Font-awesome plugin -->
    <link rel="stylesheet" href="font-awesome/css/font-awesome.min.css">
    <!-- Bootstrap  -->
    <link rel="stylesheet" href="css/bootstrap.css">
    <!--Loader-->
    <link rel="stylesheet" href="css/fakeLoader.css">
    <!-- Owl Carousel  -->
    <link rel="stylesheet" href="css/owl.carousel.min.css">
    <link rel="stylesheet" href="css/owl.theme.default.min.css">
    <!-- Style -->
    <link rel="stylesheet" href="css/style.css?v=2">

    <script src="js/modernizr-2.6.2.min.js"></script></a> </li>


</head>
<body>

<!-- Navigation -->
<header id="header">
    <div class="container-fluid-container">
        <nav class="navbar navbar-default">
            <div class="navbar-header">
                <!-- Mobile Menu Button-->
                <a href="#" class="js-nav-toggle nav-toggle" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar"></a>
                <a class="navbar-brand" href="index.php">
                    <img src="images/castlemainlogo.png" class="main">
                    <img src="images/castlemainlogo.png" class="fix">
                </a>
            </div>
            <div id="navbar" class="navbar-collapse collapse">
                <ul class="nav navbar-nav navbar-right">
                    <li class="<?= $activelink == 'index'?'active':'' ?>"><a href="index.php"><span>About</span></a> </li>
                    <li class="<?= $activelink == 'services'?'active':'' ?>"><a href="services.php"><span>Services</span></a> </li>
                    <li class="<?= $activelink == 'approach'?'active':'' ?>"><a href="approach.php"><span>Our Approach</span></a></li>
                    <li class="<?= $activelink == 'contactus'?'active':'' ?>"><a href="contactus.php"><span>Contact Us</span></a> </li>
                </ul>
            </div>
        </nav>
    </div>
</header>


</body>
</html>