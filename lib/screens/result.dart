import 'package:flutter/material.dart';
import 'package:teachiz/components/custom_button.dart';

class Result extends StatelessWidget {
  final List<Map<String, dynamic>> wrongAnsweredQuestions;

  const Result({super.key, required this.wrongAnsweredQuestions});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screen = MediaQuery.of(context).size;
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    int time = DateTime.now().difference(args['start_at']).inSeconds;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        // Wrap the column with a SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: screen.width - 40.0,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(6.0, 12.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: screen.width / 3.5,
                      width: screen.width / 3.5,
                      child: Image(
                        image: AssetImage((args['corrects'] >= 5)
                            ? 'assets/images/celebrate.png'
                            : 'assets/images/repeat.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        (args['corrects'] >= 5)
                            ? 'Congratulations!!'
                            : 'Completed!',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        (args['corrects'] >= 5)
                            ? 'You are amazing!!'
                            : 'Better luck next time!',
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    Text(
                      '${args['corrects']}/${args['list_length']} correct answers in $time seconds.',
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Wrong Answered Questions:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: wrongAnsweredQuestions.length,
                      itemBuilder: (context, index) {
                        final question = wrongAnsweredQuestions[index];
                        return ListTile(
                          title: Text(question['question']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Correct Answer: ${question['correctAnswer']}'),
                              Text('Your Answer: ${question['userAnswer']}'),
                            ],
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, 'start');
                      },
                      child: const CustomButton(
                        text: 'Play Again',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
