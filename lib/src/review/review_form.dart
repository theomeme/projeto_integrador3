import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double ratingProfessional = 0;
  double ratingApp = 0;
  late final TextEditingController _reviewController;
  late final TextEditingController _reviewAppController;

  @override
  void initState() {
    _reviewController = TextEditingController();
    _reviewAppController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avalie atendimento"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.redAccent,
            secondary: Colors.black54,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Como foi sua experiência?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text("Como foi sua experiência com o profissional?"),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                glow: false,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                unratedColor: Colors.black12,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratingProfessional = rating;
                  });
                },
              ),
              const Text("Escreva para nós como foi sua experiência"),
              TextField(
                cursorColor: Colors.redAccent,
                keyboardType: TextInputType.name,
                maxLines: 5,
                controller: _reviewController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onTapOutside: (pointerDown) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              const Text("Dê uma nota para o TeethKids"),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                maxRating: 10,
                itemSize: 35,
                glow: false,
                unratedColor: Colors.black12,
                direction: Axis.horizontal,
                itemCount: 10,
                itemPadding: const EdgeInsets.symmetric(horizontal: .5),
                itemBuilder: (context, _) => const Icon(
                  Icons.circle,
                  color: Colors.redAccent,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    ratingApp = rating;
                  });
                },
              ),
              const Text("Comente o que achou do aplicativo"),
              TextField(
                cursorColor: Colors.redAccent,
                keyboardType: TextInputType.name,
                maxLines: 3,
                controller: _reviewAppController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onTapOutside: (pointerDown) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Avaliar",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
