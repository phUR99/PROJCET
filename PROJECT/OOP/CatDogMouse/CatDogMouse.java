// CatDogMouse.java                          Written by David Wagner
// Project for Object Oriendted Programming Class

import java.util.Scanner;
import java.util.Formatter;
import java.util.Random;
import java.io.File;

public class CatDogMouse {

	//////////////////////
	// Constant Values //
	//////////////////////

	// This is the maximum number of dogs and mice that can appear in the house
	static final int MAXDOGS = 20;
	static final int MAXMICE = 20;

	// A location in the house can contain an obsatcle, player, dog or mouse
	static final char OBSTACLECHAR = 'X';
	static final char CATCHAR = 'C';
	static final char DOGCHAR = 'D';
	static final char MOUSECHAR = 'M';
	static final char UPCHAR = '^';
	static final char DOWNCHAR = 'v';
	static final char EXITCHAR = 'H';
	static final char WHIPCHAR = 'W';
	static final char CHEESECHAR = 'O';

	// The name of the high score file
	static String HIGHSCOREFILE = "CatAndDogAndMouseHighScore.txt";

	// If this is the first time you run the program, this is the high score
	static final int STARTHIGHSCORE = 0;

	// Define the size of an obstacle free center region
	// This also defines the region where the cat must start
	// And where no dogs can start
	static final int TOOCLOSE = 4;

	// Define the size of an obstructed external region on the top floor
	static final int TOOFAR = 8;

	static final int NOMOUSEINDEX = -1;

	// Define an axis to be either vertical (NORTHSOUTH) or horizontal (EASTWEST)
	static final int NORTHSOUTH = 0;
	static final int EASTWEST = 1;

	//////////////////////
	// Global Variables //
	//////////////////////

	// This is the house variable
	// It is a 2 dimensional array of characters
	static House house;
	//
	static boolean charm, power;
	// This is the count of how many dogs and mice are currently in the house
	static int numDogs;
	static int numMice;

	// This variable contains the location of the player
	static Animal player;

	// This variable conatains the locations of the dogs
	static Dog[] dogs;

	// This variable contains the locations of the mice
	static Mouse[] mice;

	// This variable contains the location of the up and down stairs
	static HouseObject upStairs, downStairs;

	static HouseObject whip, cheese;
	// This variable contains the location of the exit
	static HouseObject houseExit;

	// This is how many mice you are carrying
	static int miceCarried;

	// This is how many mice you have removed
	static int miceRemoved;

	// This is your high score, which is the tallest house you have reached so far
	static int highScore;

	// Random number generator
	static Random randomNum;

	// Scanner to read from a file or from the command line
	static Scanner input;

	// Formatter to write to a file
	static Formatter output;

	/////////////////////////////////////////////////////////////////////////
	//
	// Print out the score banner
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printScore() {
		int i, j;

		System.out.printf("\f"); // Clear the screen
		System.out.printf("\n==============================\n");
		System.out.printf("House:%d Floor:%d High Score:%d\n",
				house.getHouseNumber(), house.getFloorNumber(), highScore);
		System.out.printf("Mice Carried:%d Mice Removed:%d\n",
				miceCarried, miceRemoved);

		System.out.printf("Charm:%s Power:%s\n", (charm ? "YES" : "NO"), (power ? "YES" : "NO"));
		System.out.printf("==============================\n");
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Print out the key, explaining what the various letters are in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printKey() {
		System.out.printf("\n");
		System.out.printf("Cat (Player) = %c\n", CATCHAR);
		System.out.printf("Guard Dog = %c\n", DOGCHAR);
		System.out.printf("Mouse = %c\n", MOUSECHAR);
		System.out.printf("Up Stairs = %c\n", UPCHAR);
		System.out.printf("Down Stairs = %c\n", DOWNCHAR);
		System.out.printf("Helicopter = %c\n", EXITCHAR);
		System.out.printf("Cheese = %c\n", CHEESECHAR);
		System.out.printf("Whip = %c\n", WHIPCHAR);
		System.out.printf("\n");

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Print out the house and the key
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printScoreAndHouseAndKey() {
		printScore();
		house.printHouse();
		printKey();
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Create a new high score file
	//
	/////////////////////////////////////////////////////////////////////////

	public static void createHighScoreFile() {

		System.out.printf("Creating High Score file\n");

		try {
			output = new Formatter(HIGHSCOREFILE);
			output.format("%d\n", STARTHIGHSCORE);
		} catch (Exception error) {
			System.out.printf("Error creating new high score file\n");
		}

		output.close();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Load the high score from a file
	//
	/////////////////////////////////////////////////////////////////////////

	public static void loadHighScore() {

		try {
			// read the high score from the file
			input = new Scanner(new File(HIGHSCOREFILE));
			highScore = input.nextInt();
		} catch (Exception error) {
			// the file does not exist yet so create it
			highScore = STARTHIGHSCORE;
			createHighScoreFile();
			return;
		}

		input.close();
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Save the high score to a file
	//
	/////////////////////////////////////////////////////////////////////////

	public static void saveHighScore() {

		try {
			output = new Formatter(HIGHSCOREFILE);
			output.format("%d\n", highScore);
		}

		catch (Exception error) {
			System.out.printf("Error saving the high score to a file\n");
		}

		output.close();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// Check if the high score has been beaten
	// If yes, then save the new high score
	//
	/////////////////////////////////////////////////////////////////////////

	public static void checkAndUpdateHighScore() {

		if (miceRemoved > highScore) {
			highScore = miceRemoved;
			saveHighScore();
		}
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if the player is at location x,y
	// If the player is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean playerLocation(int x, int y) {
		if (x == player.getX() && y == player.getY()) {
			return true;
		}
		return false;
	}

	public static boolean playerLocation(Location myLocation) {
		return playerLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if the UP stairs is at location x,y
	// If the UP stairs is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean upStairsLocation(int x, int y) {
		if (x == upStairs.getX() && y == upStairs.getY()) {
			return true;
		}
		return false;
	}

	public static boolean upStairsLocation(Location myLocation) {
		return upStairsLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if the DOWN stairs is at location x,y
	// If the DOWN stairs is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean downStairsLocation(int x, int y) {
		if (x == downStairs.getX() && y == downStairs.getY()) {
			return true;
		}
		return false;
	}

	public static boolean downStairsLocation(Location myLocation) {
		return downStairsLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if the EXIT is at location x,y
	// If the EXIT is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean exitLocation(int x, int y) {
		if (x == houseExit.getX() && y == houseExit.getY()) {
			return true;
		}
		return false;
	}

	public static boolean exitLocation(Location myLocation) {
		return exitLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if a specific mouse, with the index mouseNum,
	// is at location x,y. If the mouse is at this location it returns true.
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean mouseNumberAtLocation(int x, int y, int mouseNum) {
		if (x == mice[mouseNum].getX() && y == mice[mouseNum].getY()) {
			return true;
		}
		return false;
	}

	public static boolean mouseNumberAtLocation(Location myLocation, int mouseNum) {
		return mouseNumberAtLocation(myLocation.getX(), myLocation.getY(), mouseNum);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is an integer function. It can return an integer
	//
	// This function checks if any mouse is at location x,y
	// If any mouse is at this location it returns the index of that mouse.
	// If there is no mouse then this returns -1.
	//
	/////////////////////////////////////////////////////////////////////////

	public static int mouseIndexAtLocation(int x, int y) {
		int mouseNum;

		for (mouseNum = 0; mouseNum < numMice; mouseNum++) {
			if (mouseNumberAtLocation(x, y, mouseNum)) {
				return mouseNum;
			}
		}
		return NOMOUSEINDEX;
	}

	public static int mouseIndexAtLocation(Location myLocation) {
		return mouseIndexAtLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if any mouse is at location x,y
	// If any mouse is at this location it returns true.
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean mouseLocation(int x, int y) {
		if (mouseIndexAtLocation(x, y) == NOMOUSEINDEX) {
			return false;
		}
		return true;
	}

	public static boolean mouseLocation(Location myLocation) {
		return mouseLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if the specific dog, with the number dogNumber,
	// is at location x,y. If that dog is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean dogNumberAtLocation(int x, int y, int dogNumber) {
		if (x == dogs[dogNumber].getX() &&
				y == dogs[dogNumber].getY()) {
			return true;
		}
		return false;
	}

	public static boolean dogNumberAtLocation(Location myLocation, int dogNumber) {
		return dogNumberAtLocation(myLocation.getX(), myLocation.getY(), dogNumber);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function checks if any dog is at location x,y
	// If any dog is at this location it returns true
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean dogLocation(int x, int y) {
		int dogNum;

		for (dogNum = 0; dogNum < numDogs; dogNum++) {
			if (dogNumberAtLocation(x, y, dogNum)) {
				return true;
			}
		}
		return false;
	}

	public static boolean dogLocation(Location myLocation) {
		return dogLocation(myLocation.getX(), myLocation.getY());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation starts by putting the stairs and the exit outside the house
	//
	/////////////////////////////////////////////////////////////////////////
	public static boolean whipLocation(int x, int y) {
		if (x == whip.getX() && y == whip.getY()) {
			return true;
		}
		return false;
	}

	public static boolean whipLocation(Location myLocation) {
		return whipLocation(myLocation.getX(), myLocation.getY());
	}

	public static boolean cheeseLocation(int x, int y) {
		if (x == cheese.getX() && y == cheese.getY()) {
			return true;
		}
		return false;
	}

	public static boolean cheeseLocation(Location myLocation) {
		return cheeseLocation(myLocation.getX(), myLocation.getY());
	}

	public static void initializeStairsAndExit() {
		houseExit.setXY(-1, -1);
		upStairs.setXY(-1, -1);
		downStairs.setXY(-1, -1);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds the exit to an empty location in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addExit() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		houseExit.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), EXITCHAR);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds an up stairs to an empty location in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addUpStairs() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		upStairs.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), UPCHAR);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds a down stairs to an empty location in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addDownStairs() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		downStairs.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), DOWNCHAR);
	}

	public static void addWhip() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		whip.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), WHIPCHAR);

	}

	public static void addCheese() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		cheese.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), CHEESECHAR);

	}
	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds an exit and stairs to the house if necessary
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addExitandStairs() {
		initializeStairsAndExit();
		if (house.topFloor())
			addExit();
		if (!house.bottomFloor())
			addDownStairs();
		if (!house.topFloor())
			addUpStairs();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds the player to an empty location in the house
	// The player is always added close to the center of the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addPlayer() {
		Location myLocation = new Location();

		house.chooseEmptyLocation(myLocation, randomNum);
		while (!house.closerToCenter(myLocation.getX(), myLocation.getY(), TOOCLOSE))
			house.chooseEmptyLocation(myLocation, randomNum);
		player.setLocation(myLocation);
		house.setChar(myLocation.getX(), myLocation.getY(), CATCHAR);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds the specific dog, with the number dogNumber,
	// to an empty location in the house
	// The dog is never added close to the center of the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addOneDog(int dogNumber) {
		Dog myDog = new Dog(dogNumber, house, player, DOGCHAR);
		Location myLocation = myDog.getLocation();

		house.chooseEmptyLocation(myLocation, randomNum);
		while (house.closerToCenter(myLocation.getX(), myLocation.getY(), TOOCLOSE))
			house.chooseEmptyLocation(myLocation, randomNum);
		dogs[dogNumber] = myDog;
		house.setChar(myLocation.getX(), myLocation.getY(), DOGCHAR);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds all dogs to empty locations in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addManyDogs() {
		int dogNumber;

		for (dogNumber = 0; dogNumber < numDogs; dogNumber++) {
			addOneDog(dogNumber);
		}
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds one mouse to an empty location in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addOneMouse(int mouseNumber) {
		Mouse myMouse = new Mouse(0, house, player, MOUSECHAR);
		Location myLocation = myMouse.getLocation();

		house.chooseEmptyLocation(myLocation, randomNum);
		mice[mouseNumber] = myMouse;
		house.setChar(myLocation.getX(), myLocation.getY(), MOUSECHAR);
	}

	/////////////////////////////////////////////////////////////////////////////
	//
	// This funcation copies one mouse from one position of the array to another
	//
	/////////////////////////////////////////////////////////////////////////////

	public static void copyMouse(int toIndex, int fromIndex) {
		int x, y;

		mice[toIndex].setLocation(mice[fromIndex].getLocation());
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This funcation adds all mouse to empty locations in the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void addManyMice() {
		int mouseNumber;

		for (mouseNumber = 0; mouseNumber < numMice; mouseNumber++) {
			addOneMouse(mouseNumber);
		}
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function prints out the menu, asking the user to give a direction
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printMenu() {
		System.out.printf("Which direction (N)orth, (S)outh, (E)ast, (W)est or (Q)uit: ");
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function reads one character from the user
	//
	// The character read is converted to uppercase and is returned
	//
	/////////////////////////////////////////////////////////////////////////

	public static char getCommand() {
		String commandStr;
		char commandChar = 'x';

		input = new Scanner(System.in);

		commandStr = input.nextLine();
		if (commandStr.length() > 0)
			commandChar = commandStr.charAt(0);
		commandChar = Character.toUpperCase(commandChar);

		return Character.toUpperCase(commandChar);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function waits for the user to press ENTER
	//
	/////////////////////////////////////////////////////////////////////////

	public static void pause() {
		String commandStr;
		char commandChar = 'x';

		System.out.printf("Press ENTER to continue...");
		commandStr = input.nextLine();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function changes the location of the player to x,y
	//
	/////////////////////////////////////////////////////////////////////////

	public static void changePlayerLocation(int x, int y) {
		house.setChar(player.getX(), player.getY(), ' ');

		house.setChar(x, y, CATCHAR);

		player.setXY(x, y);
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function moves the player according to the command
	// The command should be 'N', 'S', 'E', or 'W'
	//
	// The player will move North, South, East, or West according to the
	// command character unless there is an obstacle in that location.
	// If there is an obstacle in that location then the player does not move
	//
	/////////////////////////////////////////////////////////////////////////

	public static void movePlayer(char directionChar) {

		/////////////////////////
		// Write This Function //
		/////////////////////////

		//////////////////////////////////////////////////////////////
		// directionChar is 'N', 'S', 'E', or 'W' //
		// Use player.getX() and player.getY() to find the location //
		// Use changePlayerLocation(x,y) to change the location //
		// Use emptyLocation(x,y) to test if a location is empty //
		//////////////////////////////////////////////////////////////
		int curX = player.getX();
		int curY = player.getY();
		int nxtY = curY, nxtX = curX;
		switch (directionChar) {
			case 'N':
				nxtX -= 1;
				break;
			case 'S':
				nxtX += 1;
				break;
			case 'W':
				nxtY -= 1;
				break;
			case 'E':
				nxtY += 1;
				break;

		}
		if (house.outside(nxtX, nxtY))
			return;
		if (house.emptyLocation(nxtX, nxtY) ||
				house.getChar(nxtX, nxtY) == UPCHAR ||
				house.getChar(nxtX, nxtY) == DOWNCHAR ||
				house.getChar(nxtX, nxtY) == EXITCHAR ||
				house.getChar(nxtX, nxtY) == MOUSECHAR ||
				house.getChar(nxtX, nxtY) == CHEESECHAR ||
				house.getChar(nxtX, nxtY) == WHIPCHAR)
			changePlayerLocation(nxtX, nxtY);

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function moves all of the dogs
	//
	/////////////////////////////////////////////////////////////////////////

	public static void moveAllDogs() {
		int i;

		for (i = 0; i < numDogs; i++) {
			dogs[i].moveDog(power);
		}
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function moves all of the mice
	//
	/////////////////////////////////////////////////////////////////////////

	public static void moveAllMice() {

		int i;
		for (i = 0; i < numMice; i++) {
			mice[i].moveMouse(charm);
		}

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function collects the mouse if the player has found a mouse
	//
	/////////////////////////////////////////////////////////////////////////

	public static void collectMouse() {
		int mouseIndex = mouseIndexAtLocation(player.getLocation());

		// If there is no mouse here then quit this function
		if (mouseIndex == NOMOUSEINDEX)
			return;

		// Swap the last mouse in the array into this index
		copyMouse(mouseIndex, numMice - 1);
		numMice--;
		miceCarried++;

	}

	public static void eatCheese() {
		charm = true;
	}

	public static void pickUpWhip() {
		power = true;
	}
	/////////////////////////////////////////////////////////////////////////
	//
	// This function moves the player and the dogs and the mice.
	//
	/////////////////////////////////////////////////////////////////////////

	public static void movePlayerAndDogsAndMice(char directionChar) {
		// Move the mouse only if we are in house 3 or later
		if (house.getHouseNumber() >= 3 || charm)
			moveAllMice();
		// Move the player according to the direction entered
		movePlayer(directionChar);
		collectMouse();
		// Move the dogs and mouse according to their moving strategy
		moveAllDogs();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function climbs up the stairs to the
	// next higher level of the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void climbUpStairs() {
		house.setFloorNumber(house.getFloorNumber() + 1);
		// Increase the size of the house
		house.changeHouseSize(house.getHouseSize() - house.getSizeIncrement());
		// Add one dog for the next level
		if (numDogs < MAXDOGS)
			numDogs++;
		// If we have not visited this level yet, then add mice
		if (house.getMaxFloorReached() < house.getFloorNumber()) {
			house.setMaxFloorReached(house.getFloorNumber());
			numMice = numDogs * house.getHouseNumber();
		} else {
			// If we have already visited this level, then there
			// are no mice on this level
			numMice = 0;
		}
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function climb down the stairs to the
	// next lower level of the house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void climbDownStairs() {
		house.setFloorNumber(house.getFloorNumber() - 1);
		// Decrease the size of the house
		house.changeHouseSize(house.getHouseSize() + house.getSizeIncrement());
		// Remove one dog for the next level
		numDogs--;

		numMice = 0;
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function returns true if the player has reached the exit,
	// meaning that the house is finished.
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean houseFinished() {
		if (exitLocation(player.getLocation())) {
			return true;
		}
		return false;
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This is a boolean function. It can return true or false
	//
	// This function returns true if a dog has reached the player,
	// meaning that the game is lost.
	//
	/////////////////////////////////////////////////////////////////////////

	public static boolean gameLost() {
		if (dogLocation(player.getLocation())) {
			return true;
		}
		return false;
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function prints a message informing the user that he has won
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printWinMessage() {
		System.out.printf("**********************************\n");
		System.out.printf("*** You Escaped with %d ", miceCarried);
		if (miceCarried == 1)
			System.out.printf("mouse! ***\n");
		else
			System.out.printf("mice! ***\n");
		System.out.printf("**********************************\n");
		System.out.printf("\n\n");
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function prints a message informing the user that he has lost
	//
	/////////////////////////////////////////////////////////////////////////

	public static void printLoseMessage() {
		System.out.printf("++++++++++++++++++++++++\n");
		System.out.printf(" You were Caught... T.T \n");
		System.out.printf("    Your score is %d \n", miceRemoved);
		System.out.printf("++++++++++++++++++++++++\n");
		System.out.printf("\n\n");
	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function starts the player in a new house
	//
	/////////////////////////////////////////////////////////////////////////

	public static void startHouseNumber(int number) {
		house.startHouse(number);
		// Start each house with 1 dog
		numDogs = 1;
		// Start each house with the same amount of mice as the house number
		numMice = house.getHouseNumber();

		// Remove all mice carried
		miceRemoved += miceCarried;
		miceCarried = 0;

		// Update the high score with the new mice removed
		checkAndUpdateHighScore();

	}

	/////////////////////////////////////////////////////////////////////////
	//
	// This function initializes the global variables
	//
	/////////////////////////////////////////////////////////////////////////

	public static void initVariables() {
		int i;
		// Seed the random number generator
		randomNum = new Random();
		house = new House();
		dogs = new Dog[MAXDOGS];
		for (i = 0; i < MAXDOGS; i++)
			dogs[i] = new Dog(i, house, player, DOGCHAR);
		mice = new Mouse[MAXMICE];
		for (i = 0; i < MAXMICE; i++)
			mice[i] = new Mouse(i, house, player, MOUSECHAR);
		player = new Animal();
		upStairs = new HouseObject();
		downStairs = new HouseObject();
		houseExit = new HouseObject();
		whip = new HouseObject();
		cheese = new HouseObject();
		charm = false;
		power = false;
	}

	///////////////////
	// main function //
	///////////////////

	public static void main(String[] args) {
		char command;

		initVariables();

		// Load the previous high score from the high score file
		loadHighScore();

		// Start the player in the first house
		startHouseNumber(1);

		// Loop until the player wins, loses, or quits
		while (true) {
			///////////////////////////////////////

			/*
			 * try {
			 * new ProcessBuilder("cmd", "/c", "cls").inheritIO().start().waitFor();
			 * } catch (Exception e) {
			 * e.printStackTrace();
			 * }
			 */
			////////////////////////////////////////
			// Build walls and obstacles in the house
			house.buildWalls();
			house.buildObstacles(randomNum);

			// Add the dogs, mice, cat, exit, and stairs to the house
			addManyDogs();
			addManyMice();
			addPlayer();
			addExitandStairs();
			addCheese();
			addWhip();
			// Stay in this house until the player reaches a stairs
			while (true) {

				///////////////////////////////////////
				try {
					new ProcessBuilder("cmd", "/c", "cls").inheritIO().start().waitFor();
				} catch (Exception e) {
					e.printStackTrace();
				}
				///////////////////////////////////////

				// Print the house and the key explaining each letter
				printScoreAndHouseAndKey();

				// Ask the user to enter a command and get that command
				printMenu();
				command = getCommand();

				// If command is Q then quit the program
				if (command == 'Q') {
					return;
				}

				// Move the player, dogs, and mice
				// according to the command entered
				movePlayerAndDogsAndMice(command);

				// If the player is reached the up stairs, climb up
				if (upStairsLocation(player.getLocation())) {
					climbUpStairs();
					charm = false;
					power = false;
					break;
				}

				// If the player is reached the down stairs, climb down
				if (downStairsLocation(player.getLocation())) {
					climbDownStairs();
					charm = false;
					power = false;
					break;
				}
				if (cheeseLocation(player.getLocation())) {
					eatCheese();
				}
				if (whipLocation(player.getLocation())) {
					pickUpWhip();
				}
				// If the player wins then break out of the house
				// and advance to the next house
				if (houseFinished()) {
					printScoreAndHouseAndKey();
					printWinMessage();

					pause();

					startHouseNumber(house.getHouseNumber() + 1);
					charm = false;
					power = false;
					break;
				}

				// If the player loses, then quit the program
				if (gameLost()) {
					printScoreAndHouseAndKey();
					printLoseMessage();

					return;
				}

			}

		}
	}

}
