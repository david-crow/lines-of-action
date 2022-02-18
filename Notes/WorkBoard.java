/**
 * Title:
 * Description:
 * @author: David Crow
 * @version 1.0
 */

import java.util.HashMap;
import java.util.Map;

public class WorkBoard extends Board {
  static final int INF = 10000;
  Move best_move = null;  // Put your best move in here!
  int start_depth = 0;
  int totalNodesSearched = 0;
  int numLeafNodes = 0;
  boolean stoptime = true;
  public long searchtime = 0L;

  // when we have <key> black/white pieces on the board,
  // <value> is the sum of the minimum distances for each black/white piece
  // to the center of mass of all black/white pieces
  Map<Integer, Integer> sums_of_min_distances;

  // the value given to a piece on a given square
  static Integer[][] cell_values = {
    {-80, -25, -20, -20, -20, -20, -25, -80},
    {-25,  10,  10,  10,  10,  10,  10, -25},
    {-20,  10,  25,  25,  25,  25,  10, -20},
    {-20,  10,  25,  50,  50,  25,  10, -20},
    {-20,  10,  25,  50,  50,  25,  10, -20},
    {-20,  10,  25,  25,  25,  25,  10, -20},
    {-25,  10,  10,  10,  10,  10,  10, -25},
    {-80, -25, -20, -20, -20, -20, -25, -80}
  };

  public WorkBoard() {
    initSumsOfMinDistances();
  }

  public WorkBoard(WorkBoard w) {
    super(w);
    initSumsOfMinDistances();
  }

  public void initSumsOfMinDistances() {
    // create hash map and explicitly define the sum of min distances for one piece
    sums_of_min_distances = new HashMap<>();
    sums_of_min_distances.put(1, 0);

    // 0 elements in 0 concentric rings of pieces on a checkerboard
    // 1 element in 1 concentric ring of pieces on a checkerboard
    // 9 elements in 2 concentric rings of pieces on a checkerboard
    // 25 elements in 3 concentric rings of pieces on a checkerboard
    // et cetera...

    // clearly, this supports way more pieces than necessary (up to 25 per player)
    int[] rings = {0, 1, 9, 25};

    // start at 2 because we already know the sum of min distances for the first ring (when we have just 1 piece)
    for (int r = 2; r < rings.length; r++) {

      // for all pieces in a given ring
      for (int i = rings[r - 1] + 1; i <= rings[r]; i++) {

        // this is the sum of min distances for the previous rings
        int base = sums_of_min_distances.get(rings[r - 1]);

        // for i pieces, the sum of min distances is equal to base plus
        // the number of pieces in the current ring times the current ring's distance from the center
        sums_of_min_distances.put(i, base + (r - 1) * (i - rings[r - 1]));
      }
    }
  }

  /**
   * This is where your board evaluator will go. This function will be called
   * from min_max
   *
   * @return int calculated heuristic value of the board
   */

  int h_value(int player_to_move, int depth, boolean is_root) {
    if (connected(player_to_move)) { // we win :)
      return (int) ((float) INF / depth);
    } else if (connected(opponent(player_to_move))) { // they win :(
      return (int) ((float) -INF / depth);
    } else {
      // we'll need these later
      boolean is_moving = player_to_move == super.to_move;
      float concentration, mobility, centralization, uniformity, connectedness, opponent_value = 0;
      int quads = 0;

      // center of mass for the calling player's pieces
      int center_x = 0;
      int center_y = 0;

      // each piece earns a score for the square it occupies
      int sum_of_cell_values = 0;

      // we want our pieces to fit into small rectangles, so we need the edges of that rectangle
      int smallest_x = INF;
      int smallest_y = INF;
      int largest_x = 0;
      int largest_y = 0;

      // we'd like to know how many pair-wise connections exist between our pieces
      int num_connections = 0;

      // we'd like to know how many pieces we have
      int num_pieces = 0;

      // 1. count the number of moves
      // 2. sum all x- and y-coordinates
      // 3. sum the total value of the piece locations
      // 4. find the edges of a rectangle that covers all pieces
      // 5. count the number of pair-wise connections

      for (Piece p = piece_list[player_to_move]; p != null; p = p.next) {
        num_pieces++;
        center_x += p.x;
        center_y += p.y;
        sum_of_cell_values += cell_values[p.x][p.y];

        if (p.x < smallest_x) smallest_x = p.x;
        if (p.y < smallest_y) smallest_y = p.y;
        if (p.x > largest_x) largest_x = p.x;
        if (p.y > largest_y) largest_y = p.y;

        for (Piece o = piece_list[player_to_move]; o != null; o = o.next) {
          if (Math.abs(p.x - o.x) <= 1 && Math.abs(p.y - o.y) <= 1) {
            num_connections++;
          }
        }
      }

      // ---------- Concentration Heuristic ----------
      {
        // now average the x- and y-coordinates to find the center of mass
        center_x /= num_pieces;
        center_y /= num_pieces;

        // distance for a given piece is the number of squares (including diagonal moves)
        // to get from the center of mass to the piece in question
        int sum_of_distances = 0;

        // so sum of distances is... self-explanatory
        for (Piece p = piece_list[player_to_move]; p != null; p = p.next) {
          int x_distance = Math.abs(p.x - center_x);
          int y_distance = Math.abs(p.y - center_y);
          sum_of_distances += (x_distance > y_distance) ? x_distance : y_distance;
        }

        // lookup the minimum possible sum of distances for this number of pieces
        int min_sum_of_distances = sums_of_min_distances.get(num_pieces);

        // normalize the sum of distances - otherwise, the heuristic would favor fewer pieces,
        // and that's not necessarily what we want
        int surplus_of_distances = sum_of_distances - min_sum_of_distances;

        // avoid dividing by 0
        if (surplus_of_distances == 0) surplus_of_distances = 1;

        // this is a measure of how densely-packed our pieces are; closer to 1 is better
        concentration = 1f / surplus_of_distances;
      }

      // ---------- Mobility Heuristic ----------
      {
        int num_moves = 0;

        // pretend we're the other player
        if (!is_moving) {
          super.to_move = opponent(super.to_move);
        }

        for (Move m = moveOrdering(genMoves(), player_to_move, 0); m != null; m = m.next) {
          float move_value = 1;

          // if move is a capture, double the value of the move
          if (checker_of(opponent(player_to_move), m.x2, m.y2)) {
            move_value *= 2;
          }

          // if move is to an edge, halve the value of the move
          if (m.x2 == 0 || m.x2 == BOARD_INDEX || m.y2 == 0 || m.y2 == BOARD_INDEX) {
            move_value /= 2;
          }

          // if move is along an edge, halve the value of the move
          if (((m.x2 == 0 || m.x2 == BOARD_INDEX) && m.x2 == m.x1) || ((m.y2 == 0 || m.y2 == BOARD_INDEX) && m.y2 == m.y1)) {
            move_value /= 2;
          }

          num_moves += (int) move_value;
        }

        // we prefer board states with more available moves
        mobility = (float) num_moves / num_pieces;

        // mobility is on a scale of 0 to 8, so let's normalize it
        mobility /= 8;

        // make sure we don't actually change which player is moving
        if (!is_moving) {
          super.to_move = opponent(player_to_move);
        }
      }

      // ---------- Quads Heuristic ----------
      {
        // iterate over all quads with at least 3 squares actually on the checkerboard
          // (hint: out of all 81 quads, 49 satisfy this property)
        // if the center of the quad is no more than 2 squares from the center of mass,
        // and if the quad has 3 or 4 pieces

        for (int i = 0; i < BOARD_INDEX; i++) {
          for (int j = 0; j < BOARD_INDEX; j++) {
            if ((center_x - i <= 3 || i - center_x <= 2) && (center_y - j <= 3 || j - center_y <= 2)) {
              if (quadValue(i, j, player_to_move) >= 3) {
                quads++;
              }
            }
          }
        }

        // by my rough scratchpad math, we can have no more than 10 quads - let's normalize it
        quads = (int) (quads / 10f);
      }

      // ---------- Centralization Heuristic ----------
      {
        // compute the average cell value
        centralization = (float) sum_of_cell_values / num_pieces;

        // average cell value is on a scale of -80 to 50, so let's normalize it (this gives range of -1.75 to 1)
        // pieces closer to the center of the board provide better value to us
        centralization /= 50;
      }

      // ---------- Uniformity Heuristic ----------
      {
        // compute the area of the smallest rectangle that covers all pieces
        // the biggest rectangle has an area of 64, so let's normalize it
        // we prefer small rectangles to big rectangles, so compute the inverse
        uniformity = 1f / ((largest_x - smallest_x + 1) * (largest_y - smallest_y + 1) / 64f);
      }

      // ---------- Connectedness Heuristic ----------
      {
        // of course every piece is connected to itself (under the previous calculation of num_connections)
        num_connections -= num_pieces;

        // compute the average number of connections
        connectedness = (float) num_connections / num_pieces;

        // connectedness is on a scale of 0 to 8, to let's normalize it
        connectedness /= 8;
      }

      // ---------- Opponent's Heuristic ----------
      {
        // how does the opponent's state look?
        if (is_root) {
          opponent_value = h_value(opponent(player_to_move), depth, false);
        }
      }

      // the total heuristic value is a weighted sum of the individual pieces
      double h = 30 * concentration + 25 * mobility + 20 * quads + 10 * centralization + 7 * uniformity + 7 * connectedness + (is_moving ? 1 : 0);

      // to allow for diversity in board state evaluation, increase the range of the heuristic
      h *= 10;

      // we don't want the opponent to have a good board state
      h -= opponent_value;

      // we like integers
      System.out.println("Depth: " + h);
      return (int) h;
    }
  }

  void min_max_AB(int depth, int alpha, int beta, int player) {
    // perform alpha beta minimax
    best_move = null;
    min_max_AB_helper(depth, alpha, beta, player, true);
  }

  /**
   * This is where you will write min-max alpha-beta search. Note that the
   * Board class maintains a predecessor, so you don't have to deal with
   * keeping up with dynamic memory allocation.
   * The function takes the search depth, and returns the maximum value from
   * the search tree given the board and depth.
   *
   * @parama depth int the depth of the search to conduct
   * @return maximum heuristic board found value
   */
  int min_max_AB_helper(int depth, int alpha, int beta, int player, boolean is_root) {
    totalNodesSearched++;

    // if we're done searching or if we found the goal
    if (depth == 0 || connected(player)) {
      return h_value(player, depth, is_root);
    }

    // count the number of available moves
    int num_moves = 0;
    Move move_list = moveOrdering(genMoves(), player, depth);

    for (Move m = move_list; m != null; m = m.next) {
      num_moves++;
    }

    // if we don't have any moves to make
    if (num_moves == 0) {
      return (int) ((float) -INF / depth);
    }

    // otherwise, search
    int best_value;

    if (player == super.to_move) {
      best_value = -INF;

      for (Move m = move_list; m != null; m = m.next) {
        // find the value of the move
        makeMove(m);
        int test_value = min_max_AB_helper(depth - 1, alpha, beta, player, false);

        // check whether this is the best move so far
        if (test_value > best_value) {
          best_value = test_value;

          // this is the best move to make at the root so far
          if (is_root) {
            best_move = m;
          }
        }

        // undo the move
        reverseMove(m);

        // prune
        if (test_value >= beta) {
          return test_value;
        }

        // update alpha
        alpha = Math.max(alpha, best_value);
      }
    } else {
      best_value = INF;

      for (Move m = move_list; m != null; m = m.next) {
        // find the value of the move
        makeMove(m);
        int test_value = min_max_AB_helper(depth - 1, alpha, beta, opponent(player), false);

        // check whether this is the best move so far
        if (test_value > best_value) {
          best_value = test_value;

          // this is the best move to make at the root so far
          if (is_root) {
            best_move = m;
          }
        }

        // undo the move
        reverseMove(m);

        // prune
        if (test_value <= alpha) {
          return test_value;
        }

        // update beta
        beta = Math.min(beta, best_value);
      }
    }

    return best_value;
  }

  /**
   * This function is called to perform search. All it does is call min_max.
   *
   * @param depth int the depth to conduct search
   */
  void bestMove(int depth) {
    best_move = null;
    int runningNodeTotal = 0;
    totalNodesSearched = numLeafNodes = moveCount = 0;
    start_depth = 1;
    int i = 1;
    long startTime = System.currentTimeMillis();
    long elapsedTime = 0;
    long currentPeriod = 0;
    long previousPeriod = 0;
    stoptime = false;

    while ( i <= depth && !stoptime) {
      totalNodesSearched = numLeafNodes = moveCount = 0;
      start_depth = i;

      // this updates best_move
      min_max_AB(i, -INF, INF, super.to_move); // Min-Max alpha beta

      elapsedTime = System.currentTimeMillis()-startTime;
      currentPeriod = elapsedTime-previousPeriod;
      double rate = 0;
      if ( i > 3 && previousPeriod > 50 )
        rate = (currentPeriod - previousPeriod)/previousPeriod;

      runningNodeTotal += totalNodesSearched;
      System.out.println("Depth: " + i +" Time: " + elapsedTime/1000.0 + " Nodes Searched: " + totalNodesSearched + " Leaf Nodes: " + numLeafNodes);

      // increment indexes: increase by two to avoid swapping between optimistic and pessimistic results
      i=i+2;

      if ( (elapsedTime+(rate+1.0)*currentPeriod) > searchtime )
        stoptime = true;
    }

    System.out.println("Nodes per Second = " + runningNodeTotal/(elapsedTime/1000.0));
    if (best_move == null  || best_move.piece == null) {
      throw new Error ("No Move Available - Search Error!");
    }
  }
}