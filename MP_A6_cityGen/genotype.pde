// genotype for building
class Genotype
{
    // genes; 0 = shape code, 1 = usage, 2 = height, 3 = offset, 4 = footprint shape, 5 = colour modifier
    int[] m_genes = new int [g_num_genes];
    // choices for each gene
    int[] m_gene_max = {12, 6, 8, 8, 8, 8};
    // matrix to set allowable usage (ref phenotype) for given shape code; 1 denotes valid shape
    int[][] m_usage = {
    //   0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11 (shape code)
        {1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0},   // 0 (usage)
        {0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0},   // 1
        {0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0},   // 2
        {0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0},   // 3
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},   // 4
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},   // 5
    };
    String m_usage_string;
    // mutation rate in % (max 100)
    float m_mutation_rate = 5.0;
    // list to save allowed usage for given shape code, eg. {0, 1, 2} for shape code 3;
    ArrayList<Integer> m_allow_usage = new ArrayList<Integer>();
    // empty constructor; generate random shape code (not used)
    Genotype() {
        m_genes[0] = (int)random(0, m_gene_max[0]);
        setRandomGene1(m_genes[0]);
        setRandomGene2to5();
        setUsage(m_genes[1]);
    }
    // constructor with shape code; generate rest of genes. Use for all additional buildings
    Genotype(int g0) {
        m_genes[0] = g0;
        setRandomGene1(m_genes[0]);
        setRandomGene2to5();
        setUsage(m_genes[1]);
    }
    // constructor with genes passed in for initial buildings.
    Genotype(int[] genes) {
        if (m_genes.length == genes.length) {
            m_genes = genes;
        } else {
            println("gene length must be " + m_genes.length);
        }
        setUsage(m_genes[1]);
    }
    //returns child genotype by crossing over this gene with other gene
    Genotype crossover(Genotype father_geno, Genotype mother_geno) {
        // firstly instantiate genes as clone of this
        Genotype child_geno = new Genotype(this.m_genes);
        // for genes 2 and up, equal chance of inheriting gene from either parent
        for (int i = 2; i < m_gene_max.length; ++i) {
            if (random(0, 1) < 0.5) {
                child_geno.m_genes[i] = father_geno.m_genes[i];
            } else {
                child_geno.m_genes[i] = mother_geno.m_genes[i];
            }
        }
        return child_geno;
    }
    // returns gene value at given index
    int getGene(int gene_index) {
        if (gene_index < m_genes.length && gene_index >= 0) {
            return m_genes[gene_index];
        } else {
            println("invalid gene index; enter index from 0 to " + (m_genes.length - 1));
            return -1;
        }
    }
    // mutates gene based on specified mutation rate
    void mutate() {
        // shape (gene 0) is predefined, usage (gene 1) is selected based on shape.
        for (int i = 2; i < m_gene_max.length; ++i) {
            if (random(100) < m_mutation_rate) {
                m_genes[i] = (int)random(0, m_gene_max[i]);
                // println("gene " + i + " mutated");
            }
        }
    }
    // for debugging
    void printGenes() {
        for (int i = 0; i < m_genes.length; ++i) {
            print(i + " = " +  m_genes[i] + ", ");
        }
        println();
    }
    // given shape (gene 0), generate random usage (gene 1) from m_usage matrix
    void setRandomGene1(int g0) {
        m_allow_usage.clear();
        if (g0 < m_usage[0].length) {
            for (int i = 0; i < m_usage.length; ++i) {
                if (m_usage[i][g0] == 1) {
                    m_allow_usage.add(i);
                }
            }
        } else {
            println("invalid gene");
        }
        // println(m_allow_usage);
        // set gene1 to random usage from m_allow_usage list
        int t_rand_index = (int)random(0, m_allow_usage.size());
        m_genes[1] = m_allow_usage.get(t_rand_index);
        // println("gene 1 index = " + t_rand_index + ", gene 1 = " + m_genes[1]);
    }
    void setRandomGene2to5() {
        for (int i = 2; i < m_gene_max.length; ++i) {
            m_genes[i] = (int)random(0, m_gene_max[i]);
        }
    }
    // sets usage string
    void setUsage(int usage) {
        switch (usage) {
            case 0:
                m_usage_string = "Residential";
                break;
            case 1:
                m_usage_string = "Retail";
                break;
            case 2:
                m_usage_string = "Office";
                break;
            case 3:
                m_usage_string = "Industrial";
                break;
            case 4:
                m_usage_string = "Leisure";
                break;
            case 5:
                m_usage_string = "Park";
                break;
            default :
                m_usage_string = "Unknown";
                break;
        }
    }
}
