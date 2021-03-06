#ifndef CONTINUITY_N_H
#define CONTINUITY_N_H

#include <vector>
#include "parameters.h"  //needs this to know what parameters are
#include "constants.h"

class Continuity_n
{
public:
    Continuity_n(const Parameters &params);

    //!Sets up the matrix equation An*n = bn for continuity equation for electrons.
    //!\param V stores the voltage and is needed to calculate Bernoulli fnc.'s.
    //!\param Un stores the net generation rate, needed for the right hand side.
    void setup_eqn(const std::vector<double> &V, const std::vector<double> &Un);

    //getters (const keyword ensures that fnc doesn't change anything)
    std::vector<double> get_main_diag() const {return main_diag;}
    std::vector<double> get_upper_diag() const {return upper_diag;}
    std::vector<double> get_lower_diag() const {return lower_diag;}
    std::vector<double> get_rhs() const {return rhs;}
    std::vector<double> get_n_mob() const {return n_mob;}
    std::vector<double> get_B_n1() const {return B_n1;}
    std::vector<double> get_B_n2() const {return B_n2;}
    double get_n_leftBC() const {return n_leftBC;}
    double get_n_rightBC() const {return n_rightBC;}

private:
    std::vector<double> main_diag;
    std::vector<double> upper_diag;
    std::vector<double> lower_diag;
    std::vector<double> rhs;
    std::vector<double> n_mob;
    std::vector<double> B_n1;  //bernoulli (+dV)
    std::vector<double> B_n2;  //bernoulli (-dV)
    double Cn;
    double n_leftBC;        //this is anode
    double n_rightBC;

    //!Calculates the Bernoulli functions and updates member arrays
    //! \param B_n1 = B(+dV) and \param B_n2 = (-dV)
    void BernoulliFnc_n(const std::vector<double> &V);

    void set_main_diag();
    void set_upper_diag();
    void set_lower_diag();
    void set_rhs(const std::vector<double> &Un);
};

#endif // CONTINUITY_N_H
